import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/widgets/date_picker_field.dart';

class EditAccommodationPage extends StatefulWidget {
  final Accommodation accommodation;
  final String docId;

  const EditAccommodationPage(
      {super.key, required this.accommodation, required this.docId});

  @override
  State<EditAccommodationPage> createState() => _EditAccommodationPageState();
}

class _EditAccommodationPageState extends State<EditAccommodationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _checkInDateController;
  late TextEditingController _checkOutDateController;
  late TextEditingController _bookingController;
  late TextEditingController _roomTypeController;
  late TextEditingController _pricePerNightController;
  late TextEditingController _facilitiesController;

  @override
  void initState() {
    super.initState();
    final a = widget.accommodation;
    _nameController = TextEditingController(text: a.name);
    _locationController = TextEditingController(text: a.location);
    _checkInDateController = TextEditingController(text: a.checkInDate);
    _checkOutDateController = TextEditingController(text: a.checkOutDate);
    _bookingController = TextEditingController(text: a.bookingConfirmation);
    _roomTypeController = TextEditingController(text: a.roomType);
    _pricePerNightController =
        TextEditingController(text: a.pricePerNight.toString());
    _facilitiesController = TextEditingController(text: a.facilities);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Check that check-in is before check-out
    final checkIn = DateTime.tryParse(_checkInDateController.text.trim());
    final checkOut = DateTime.tryParse(_checkOutDateController.text.trim());

    if (checkIn != null && checkOut != null && checkIn.isAfter(checkOut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Check-in date must be before check-out date.')),
      );
      return;
    }

    final updated = Accommodation(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      checkInDate: _checkInDateController.text.trim(),
      checkOutDate: _checkOutDateController.text.trim(),
      bookingConfirmation: _bookingController.text.trim(),
      roomType: _roomTypeController.text.trim(),
      pricePerNight:
          double.tryParse(_pricePerNightController.text.trim()) ?? 0.0,
      facilities: _facilitiesController.text.trim(),
      itineraryFirestoreId: widget.accommodation.itineraryFirestoreId,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(updated.itineraryFirestoreId)
        .collection('accommodations')
        .doc(widget.docId)
        .set(updated.toMap());

    final tripDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(updated.itineraryFirestoreId)
        .get();

    final itinerary =
        Itinerary.fromMap(tripDoc.data()!, firestoreId: tripDoc.id);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => TripDetailsPage(trip: itinerary)),
      (route) => route.isFirst,
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: isDate,
        decoration: InputDecoration(labelText: label),
        onTap: isDate
            ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.text = picked.toLocal().toString().split(' ')[0];
                }
              }
            : null,
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Accommodation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField('Name', _nameController),
                _buildField('Location', _locationController),
                DatePickerField(
                    controller: _checkInDateController, label: 'Check-In Date'),
                DatePickerField(
                    controller: _checkOutDateController,
                    label: 'Check-Out Date'),
                _buildField('Booking Confirmation', _bookingController),
                _buildField('Room Type', _roomTypeController),
                _buildField('Price Per Night', _pricePerNightController),
                _buildField('Facilities', _facilitiesController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
