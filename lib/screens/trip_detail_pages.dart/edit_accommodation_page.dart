import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/widgets/date_picker_field.dart';

class EditAccommodationPage extends StatefulWidget {
  final Accommodation accommodation;
  final String docId;
  final bool isViewer;
  final String ownerUid;

  const EditAccommodationPage(
      {super.key,
      required this.accommodation,
      required this.docId,
      required this.ownerUid,
      this.isViewer = false});

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

    try {
      final uid = widget.ownerUid;

      if (uid == null) throw Exception("No user signed in");

      debugPrint("🏨 Updated accommodation map: ${updated.toMap()}");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('itineraries')
          .doc(updated.itineraryFirestoreId)
          .collection('accommodations')
          .doc(widget.docId)
          .set(updated.toMap());

      await DatabaseHelper.instance.insertAccommodation(updated);

      final tripDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('itineraries')
          .doc(updated.itineraryFirestoreId)
          .get();

      final itinerary =
          Itinerary.fromMap(tripDoc.data()!, firestoreId: tripDoc.id);

      Navigator.pop(context, 'updated');
    } catch (e) {
      debugPrint("❌ Failed to update accommodation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update accommodation: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isViewer) {
      Future.microtask(() {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You don't have permission to edit.")),
        );
      });
      return const Scaffold();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Accommodation')),
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
