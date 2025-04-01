import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/trip.dart';

class EditTripPage extends StatefulWidget {
  final Trip trip;

  const EditTripPage({super.key, required this.trip});

  @override
  _EditTripsPageState createState() => _EditTripsPageState();
}

class _EditTripsPageState extends State<EditTripPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _destinationController;
  late TextEditingController _dateController;
  late TextEditingController _durationController;
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _vibeController;
  late TextEditingController _descriptionController;
  late TextEditingController _commentsController;
  late TextEditingController _activitiesController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.trip.destination);
    _dateController = TextEditingController(text: widget.trip.date);
    _durationController = TextEditingController(text: widget.trip.duration);
    _nameController = TextEditingController(text: widget.trip.name);
    _locationController = TextEditingController(text: widget.trip.location);
    _vibeController = TextEditingController(text: widget.trip.vibe);
    _descriptionController = TextEditingController(text: widget.trip.description);
    _commentsController = TextEditingController(text: widget.trip.comments);
    _activitiesController = TextEditingController(text: widget.trip.activities.join(","));
    if (widget.trip.image != null) {
      _image = File(widget.trip.image!);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      Trip updatedTrip = Trip(
        id: widget.trip.id,  // Retain the ID
        destination: _destinationController.text,
        date: _dateController.text,
        duration: _durationController.text,
        name: _nameController.text,
        image: _image?.path,  // Updated image path
        friends: widget.trip.friends,
        start_date: _dateController.text,
        end_date: widget.trip.end_date, // End date might remain the same
        vibe: _vibeController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        comments: _commentsController.text,
        activities: _activitiesController.text.split(","),
      );

      await DatabaseHelper.instance.updateTrip(updatedTrip);

      Navigator.pop(context, updatedTrip);  // Return the updated trip
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
                _buildTextField("Destination", _destinationController),
                _buildTextField("Date", _dateController),
                _buildTextField("Duration", _durationController),
                _buildTextField("Trip Name", _nameController),
                _buildTextField("Location", _locationController),
                _buildTextField("Vibe", _vibeController),
                _buildTextField("Description", _descriptionController,
                    maxLines: 3),
                _buildTextField("Comments", _commentsController, maxLines: 3),
                _buildTextField(
                    "Activities (comma-separated)", _activitiesController),
                const SizedBox(height: 10),
                Text("Upload Picture",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: _pickImage,
                  child: _image != null
                      ? Image.file(_image!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover)
                      : Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 50, color: Colors.black54),
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTrip,
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}