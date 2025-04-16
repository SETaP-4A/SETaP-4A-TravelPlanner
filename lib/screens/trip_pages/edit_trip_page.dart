import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditTripPage extends StatefulWidget {
  final Map<String, dynamic> trip;

  const EditTripPage({super.key, required this.trip});

  @override
  EditTripPageState createState() => EditTripPageState();
}

class EditTripPageState extends State<EditTripPage> {
  late Map<String, dynamic> trip;
  late Map<String, dynamic> editTrip;

  TextEditingController _destinationController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _vibeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _commentsController = TextEditingController();
  TextEditingController _activitiesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    trip = widget.trip;
    _destinationController = TextEditingController(text: trip["destination"]);
    _dateController = TextEditingController(text: trip["start_date"]);
    _durationController = TextEditingController(text: trip["duration"]);
    _nameController = TextEditingController(text: trip["name"]);
    _locationController = TextEditingController(text: trip["location"]);
    _vibeController = TextEditingController(text: trip["vibe"]);
    _descriptionController = TextEditingController(text: trip["description"]);
    _commentsController = TextEditingController(text: trip["comments"]);
    _activitiesController =
        TextEditingController(text: trip["activities"].join(", "));
  }

  final _formKey = GlobalKey<FormState>();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void saveTrip(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Trip")),
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
                  "Activities (comma-separated)",
                  _activitiesController,
                ),
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
                  onPressed: () => saveTrip(context),
                  child: const Text("Save Trip"),
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
