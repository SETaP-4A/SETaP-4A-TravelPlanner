import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/widgets/date_time_field.dart';

class EditActivityPage extends StatefulWidget {
  final Activity activity;
  final String docId;
  final String ownerUid;
  final bool isViewer;

  const EditActivityPage({
    super.key,
    required this.activity,
    required this.docId,
    required this.ownerUid,
    this.isViewer = false,
  });

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

    try {
      if (kIsWeb) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerUid)
            .collection('itineraries')
            .doc(widget.activity.itineraryFirestoreId)
            .collection('activities')
            .doc(widget.docId)
            .set(updated.toMap(), SetOptions(merge: true));
      } else {
        // Sync to Firestore even on Android
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerUid)
            .collection('itineraries')
            .doc(widget.activity.itineraryFirestoreId)
            .collection('activities')
            .doc(widget.docId)
            .set(updated.toMap(), SetOptions(merge: true));

        // Still update local cache
        await DatabaseHelper.instance.insertActivity(updated);
      }

      Navigator.pop(context, 'updated');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update activity: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isViewer) {
      Future.microtask(() {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("You don't have permission to edit this activity.")),
        );
      });
      return const Scaffold(body: SizedBox());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Activity')),
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
