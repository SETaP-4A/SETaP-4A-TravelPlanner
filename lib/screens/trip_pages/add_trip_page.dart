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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');

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

  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      try {
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
            userId: null,
          ).toMap();

          await firestore
              .collection('users')
              .doc(uid)
              .collection('itineraries')
              .add(tripMap);
        } else {
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
          );

          await DatabaseHelper.instance.insertItinerary(newTrip);
        }

        Navigator.pop(context, true);
      } catch (e) {
        print('❌ Failed to save trip: $e');
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
                _buildTextField('Trip Name', _nameController, isRequired: true),
                _buildTextField('Destination', _locationController,
                    isRequired: true),
                _buildDateField(
                    'Start Date (e.g., May 10, 2025)', _startDateController,
                    isRequired: true),
                _buildDateField(
                    'End Date (e.g., May 15, 2025)', _endDateController,
                    isRequired: true),
                _buildTextField('Description', _descriptionController),
                _buildTextField('Comments', _commentsController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTrip,
                  child: const Text('Save Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(controller, label),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}
