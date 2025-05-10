import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/widgets/date_time_field.dart';

class EditActivityPage extends StatefulWidget {
  final Activity activity;
  final String docId;

  const EditActivityPage(
      {super.key, required this.activity, required this.docId});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _locationController;
  late TextEditingController _dateTimeController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    _nameController = TextEditingController(text: a.name);
    _typeController = TextEditingController(text: a.type);
    _locationController = TextEditingController(text: a.location);
    _dateTimeController = TextEditingController(text: a.dateTime);
    _durationController = TextEditingController(text: a.duration);
    _notesController = TextEditingController(text: a.notes);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Activity(
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      location: _locationController.text.trim(),
      dateTime: _dateTimeController.text.trim(),
      duration: _durationController.text.trim(),
      notes: _notesController.text.trim(),
      itineraryFirestoreId: widget.activity.itineraryFirestoreId,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      if (kIsWeb) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('itineraries')
            .doc(widget.activity.itineraryFirestoreId)
            .collection('activities')
            .doc(widget.docId)
            .set(updated.toMap());
      } else {
        await DatabaseHelper.instance.insertActivity(updated); // SQLite path
      }

      final itineraryDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('itineraries')
          .doc(widget.activity.itineraryFirestoreId)
          .get();

      final itinerary =
          Itinerary.fromMap(itineraryDoc.data()!, firestoreId: itineraryDoc.id);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TripDetailsPage(trip: itinerary)),
        (route) => route.isFirst,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update activity: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Activity')),
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

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
      ),
    );
  }
}
