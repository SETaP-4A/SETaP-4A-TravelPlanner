import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/widgets/date_picker_field.dart';

class AddAccommodationPage extends StatefulWidget {
  final String itineraryFirestoreId;
  final String ownerUid;

  const AddAccommodationPage(
      {super.key, required this.itineraryFirestoreId, required this.ownerUid});

  @override
  State<AddAccommodationPage> createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _checkInDateController = TextEditingController();
  final TextEditingController _checkOutDateController = TextEditingController();
  final TextEditingController _bookingController = TextEditingController();
  final TextEditingController _roomTypeController = TextEditingController();
  final TextEditingController _pricePerNightController =
      TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();

  void _saveAccommodation() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validate that check-in is before check-out
    final checkIn = DateTime.tryParse(_checkInDateController.text.trim());
    final checkOut = DateTime.tryParse(_checkOutDateController.text.trim());

    if (checkIn != null && checkOut != null && checkIn.isAfter(checkOut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Check-in date must be before check-out date.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not signed in.')),
      );
      return;
    }

    final newAccommodation = Accommodation(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      checkInDate: _checkInDateController.text.trim(),
      checkOutDate: _checkOutDateController.text.trim(),
      bookingConfirmation: _bookingController.text.trim(),
      roomType: _roomTypeController.text.trim(),
      pricePerNight:
          double.tryParse(_pricePerNightController.text.trim()) ?? 0.0,
      facilities: _facilitiesController.text.trim(),
      itineraryFirestoreId: widget.itineraryFirestoreId,
    );

    try {
      if (kIsWeb) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerUid)
            .collection('itineraries')
            .doc(widget.itineraryFirestoreId)
            .collection('accommodations')
            .add(newAccommodation.toMap());
      } else {
        await DatabaseHelper.instance.insertAccommodation(newAccommodation);
      }

      final itinerary =
          await _fetchTripByFirestoreId(widget.itineraryFirestoreId);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => TripDetailsPage(trip: itinerary)),
        (route) => route.isFirst,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save accommodation: $e")),
      );
    }
  }

  Future<Itinerary> _fetchTripByFirestoreId(String firestoreId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ownerUid)
        .collection('itineraries')
        .doc(firestoreId)
        .get();

    if (!doc.exists) throw Exception("Trip not found");

    final rawData = doc.data()!;
    return Itinerary.fromMap(rawData, firestoreId: doc.id)
        .copyWith(permission: 'editor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Accommodation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField('Name', _nameController, isRequired: true),
                _buildField('Location', _locationController, isRequired: true),
                DatePickerField(
                  controller: _checkInDateController,
                  label: 'Check-In Date',
                  isRequired: true,
                ),
                DatePickerField(
                  controller: _checkOutDateController,
                  label: 'Check-Out Date',
                  isRequired: true,
                ),
                _buildField('Booking Confirmation', _bookingController),
                _buildField('Room Type', _roomTypeController),
                _buildField('Price per Night', _pricePerNightController),
                _buildField('Facilities', _facilitiesController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAccommodation,
                  child: const Text('Save Accommodation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(fontSize: 16, color: themeColor),
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
        validator: isRequired && (controller.text.trim().isEmpty)
            ? (_) => 'Please enter $label'
            : null,
      ),
    );
  }
}
