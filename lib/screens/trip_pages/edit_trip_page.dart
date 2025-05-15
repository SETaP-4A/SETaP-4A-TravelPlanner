import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/add_accommodation_page.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/add_activity_page.dart';
import 'package:setap4a/screens/trip_detail_pages.dart/add_flight_page.dart';

class EditTripPage extends StatefulWidget {
  final Itinerary trip;

  const EditTripPage({super.key, required this.trip});

  @override
  EditTripPageState createState() => EditTripPageState();
}

class EditTripPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _titleController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _commentsController;

  @override
  void initState() {
    super.initState();

    // Pre-fill form fields using existing trip data
    _titleController = TextEditingController(text: widget.trip.title ?? '');
    _startDateController =
        TextEditingController(text: widget.trip.startDate ?? '');
    _endDateController = TextEditingController(text: widget.trip.endDate ?? '');
    _locationController =
        TextEditingController(text: widget.trip.location ?? '');
    _descriptionController =
        TextEditingController(text: widget.trip.description ?? '');
    _commentsController =
        TextEditingController(text: widget.trip.comments ?? '');
  }

  // Opens a calendar to let the user pick a date
  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('MMMM dd, yyyy').parse(controller.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = DateFormat('MMMM dd, yyyy').format(pickedDate);
    }
  }

  // Handles validation and saving of trip changes
  void _saveTrip() async {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final start = dateFormat.parse(_startDateController.text.trim());
    final end = dateFormat.parse(_endDateController.text.trim());

    // Validate that start date is before end date
    if (start.isAfter(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        final updatedTrip = Itinerary(
          id: widget.trip.id,
          firestoreId: widget.trip.firestoreId,
          title: _titleController.text.trim(),
          startDate: _startDateController.text.trim(),
          endDate: _endDateController.text.trim(),
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          comments: _commentsController.text.trim().isNotEmpty
              ? _commentsController.text.trim()
              : null,
          userId: widget.trip.userId,
          ownerUid: widget.trip.ownerUid,
          collaborators: widget.trip.collaborators,
          permission: widget.trip.permission,
        );

        final firestore = FirebaseFirestore.instance;

        // Update in Firestore if trip is already stored remotely
        if (widget.trip.firestoreId != null && widget.trip.ownerUid != null) {
          await firestore
              .collection('users')
              .doc(widget.trip.ownerUid)
              .collection('itineraries')
              .doc(widget.trip.firestoreId)
              .update(updatedTrip.toMap());
        }

        // Also update in local database if on mobile and user is the trip owner
        if (!kIsWeb &&
            FirebaseAuth.instance.currentUser?.uid == widget.trip.ownerUid) {
          await DatabaseHelper.instance.updateItinerary(updatedTrip);
        }

        Navigator.pop(
            context, true); // Notify previous screen of successful update
      } catch (e) {
        print('Failed to update trip: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update trip')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Trip")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12.0, bottom: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Trip Details',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _buildTextField('Trip Name', _titleController,
                    isRequired: true),
                _buildTextField('Destination', _locationController,
                    isRequired: true),
                _buildDateField('Start Date', _startDateController,
                    isRequired: true),
                _buildDateField('End Date', _endDateController,
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
                  child: const Text('Save Changes'),
                ),

                // Section for quickly adding new trip elements
                const SizedBox(height: 40),
                Text("Add Items",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.hotel),
                        label: const Text('Accommodation'),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddAccommodationPage(
                                itineraryFirestoreId: widget.trip.firestoreId!,
                                ownerUid: widget.trip.ownerUid!,
                              ),
                            ),
                          );
                          if (result == 'refresh') setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions_walk),
                        label: const Text('Activity'),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddActivityPage(
                                itineraryFirestoreId: widget.trip.firestoreId!,
                                ownerUid: widget.trip.ownerUid!,
                              ),
                            ),
                          );
                          if (result == 'refresh') setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.flight),
                    label: const Text('Flight'),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFlightPage(
                            itineraryFirestoreId: widget.trip.firestoreId!,
                            ownerUid: widget.trip.ownerUid!,
                          ),
                        ),
                      );
                      if (result == 'refresh') setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable text input field with validation
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
                fontWeight: FontWeight.normal,
                color: themeColor,
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

  // Reusable date field with calendar picker and read-only input
  Widget _buildDateField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
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
                fontWeight: FontWeight.normal,
                color: themeColor,
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
