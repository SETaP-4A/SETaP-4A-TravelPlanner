import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:intl/intl.dart';
import 'package:setap4a/widgets/date_time_field.dart';

class AddActivityPage extends StatefulWidget {
  final String itineraryFirestoreId;

  const AddActivityPage({super.key, required this.itineraryFirestoreId});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  void _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not signed in.')),
      );
      return;
    }

    final newActivity = Activity(
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      location: _locationController.text.trim(),
      dateTime: _dateTimeController.text.trim(),
      duration: _durationController.text.trim(),
      notes: _notesController.text.trim(),
      itineraryFirestoreId: widget.itineraryFirestoreId,
    );

    try {
      if (kIsWeb) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('itineraries')
            .doc(widget.itineraryFirestoreId)
            .collection('activities')
            .add(newActivity.toMap());
      } else {
        await DatabaseHelper.instance.insertActivity(newActivity);
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
        SnackBar(content: Text("Failed to save activity: $e")),
      );
    }
  }

  Future<Itinerary> _fetchTripByFirestoreId(String firestoreId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not signed in");

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('itineraries')
        .doc(firestoreId)
        .get();

    if (!doc.exists) throw Exception("Trip not found");

    return Itinerary.fromMap(doc.data()!, firestoreId: doc.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField('Name', _nameController),
                _buildField('Type', _typeController),
                _buildField('Location', _locationController),
                DateTimeField(
                    controller: _dateTimeController, label: 'Date & Time'),
                _buildField('Duration', _durationController),
                _buildField('Notes', _notesController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveActivity,
                  child: const Text('Save Activity'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isDateTime = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: isDateTime,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
      ),
    );
  }
}
