import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/activity.dart';
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

  late TextEditingController _titleController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _commentsController;

  List<Flight> _flights = [];
  List<Accommodation> _accommodations = [];
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
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
    _loadData();
  }

  void _loadData() async {
    final flights = await DatabaseHelper.instance
        .loadFlightsForItinerary(widget.trip.firestoreId!);
    final accommodations = await DatabaseHelper.instance
        .loadAccommodationsForItinerary(widget.trip.firestoreId!);
    final activities = await DatabaseHelper.instance
        .loadActivitiesForItinerary(widget.trip.firestoreId!);

    setState(() {
      _flights = flights;
      _accommodations = accommodations;
      _activities = activities;
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('MMMM dd, yyyy').format(pickedDate);
    }
  }

  void _saveTrip() async {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final start = dateFormat.parse(_startDateController.text);
    final end = dateFormat.parse(_endDateController.text);

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
          title: _titleController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          location: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          comments: _commentsController.text.isNotEmpty
              ? _commentsController.text
              : null,
          userId: widget.trip.userId,
        );

        await DatabaseHelper.instance.updateItinerary(updatedTrip);
        Navigator.pop(context, true);
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
              children: [
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
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // ✅ Save Changes button (full width)
                    ElevatedButton(
                      onPressed: _saveTrip,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Save Changes'),
                    ),

                    const SizedBox(height: 30),

                    // ✅ Horizontal row of Add buttons
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.flight),
                          label: const Text('Flight'),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddFlightPage(
                                  itineraryFirestoreId:
                                      widget.trip.firestoreId!,
                                ),
                              ),
                            );
                            if (result == 'refresh') _loadData();
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.hotel),
                          label: const Text('Accommodation'),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddAccommodationPage(
                                  itineraryFirestoreId:
                                      widget.trip.firestoreId!,
                                ),
                              ),
                            );
                            if (result == 'refresh') _loadData();
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.directions_walk),
                          label: const Text('Activity'),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddActivityPage(
                                  itineraryFirestoreId:
                                      widget.trip.firestoreId!,
                                ),
                              ),
                            );
                            if (result == 'refresh') _loadData();
                          },
                        ),
                      ],
                    ),
                  ],
                )
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
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          if (label == 'Trip Name' && value!.length > 50) {
            return 'Trip name too long';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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
        onTap: () => _pickDate(controller),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
