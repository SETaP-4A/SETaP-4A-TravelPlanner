import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');

  // Opens a date picker and assigns selected date to the controller
  Future<void> _selectDate(
      TextEditingController controller, String label) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      controller.text = _dateFormat.format(picked);
    }
  }

  // Handles validation and saving logic when the form is submitted
  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Make sure the start date isn't after the end date
        final start = _dateFormat.parse(_startDateController.text);
        final end = _dateFormat.parse(_endDateController.text);
        if (start.isAfter(end)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start date must be before end date')),
          );
          return;
        }

        final firestore = FirebaseFirestore.instance;

        if (kIsWeb) {
          // Web-specific save logic (uses SharedPreferences for UID)
          final prefs = await SharedPreferences.getInstance();
          final uid = prefs.getString('active_uid');

          if (uid == null) throw Exception("No UID in shared preferences");

          final tripMap = Itinerary(
            title: _nameController.text.trim(),
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            comments: _commentsController.text.trim().isEmpty
                ? null
                : _commentsController.text.trim(),
            userId: null, // Not needed on web
            ownerUid: uid,
          ).toMap();

          await firestore
              .collection('users')
              .doc(uid)
              .collection('itineraries')
              .add(tripMap);
        } else {
          // Android/iOS logic — also saves to SQLite
          final currentUser = await AuthService.getCurrentLocalUser();
          final newTrip = Itinerary(
            title: _nameController.text.trim(),
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            comments: _commentsController.text.trim().isEmpty
                ? null
                : _commentsController.text.trim(),
            userId: currentUser.id,
            ownerUid: currentUser.uid,
          );

          await DatabaseHelper.instance.insertItinerary(newTrip);
        }

        Navigator.pop(context, true); // Signal success to the previous screen
      } catch (e) {
        print('Failed to save trip: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save trip: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Trip Name *', _nameController,
                    isRequired: true),
                _buildTextField('Destination *', _locationController,
                    isRequired: true),
                _buildDateField('Start Date *', _startDateController,
                    isRequired: true),
                _buildDateField('End Date *', _endDateController,
                    isRequired: true),
                _buildTextField('Description', _descriptionController),
                _buildTextField('Comments', _commentsController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveTrip,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Save Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generic text field builder with optional validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          if (label == 'Trip Name' && value!.length > 50) {
            return 'Trip name too long';
          }
          return null;
        },
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label.replaceAll(' *', ''),
              style: TextStyle(
                fontSize: 16,
                color: themeColor,
                fontWeight: FontWeight.normal,
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      )
                    ]
                  : [],
            ),
          ),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  // Date field builder with read-only input and calendar picker
  Widget _buildDateField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Prevent manual typing
        onTap: () => _selectDate(controller, label),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label.replaceAll(' *', ''),
              style: TextStyle(
                fontSize: 16,
                color: themeColor,
                fontWeight: FontWeight.normal,
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      )
                    ]
                  : [],
            ),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
