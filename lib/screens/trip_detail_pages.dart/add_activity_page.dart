import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/widgets/date_time_field.dart';

class AddActivityPage extends StatefulWidget {
  final String itineraryFirestoreId;
  final String? ownerUid;

  const AddActivityPage(
      {super.key, required this.itineraryFirestoreId, required this.ownerUid});

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
            .doc(widget.ownerUid)
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
      appBar: AppBar(title: const Text('Add Activity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField('Name', _nameController, isRequired: true),
                _buildField('Type', _typeController, isRequired: true),
                _buildField('Location', _locationController, isRequired: true),
                DateTimeField(
                    controller: _dateTimeController,
                    label: 'Date & Time',
                    isRequired: true),
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
              style: TextStyle(
                fontSize: 16,
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
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
