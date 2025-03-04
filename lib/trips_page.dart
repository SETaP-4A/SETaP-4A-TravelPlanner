import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'trip_details_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final List<Map<String, dynamic>> trips = [
    {
      "destination": "Paris, France",
      "date": "March 15, 2025",
      "duration": "7 days",
      "name": "Springtime in Paris",
      "image": "assets/paris.jpg",
      "friends": ["Alice", "Bob"],
      "start_date": "March 15, 2025",
      "end_date": "March 22, 2025",
      "vibe": "Romantic",
      "location": "Paris, France",
      "description":
          "Exploring the city of love, visiting the Eiffel Tower, and enjoying French cuisine.",
      "comments":
          "Excited for this trip! Need to book the Louvre tickets in advance.",
      "activities": ["Eiffel Tower", "Louvre Museum", "Seine River Cruise"]
    }
  ];

  void _addNewTrip(Map<String, dynamic> newTrip) {
    setState(() {
      trips.add(newTrip);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Trips")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trips.isNotEmpty)
              _buildTripCard(context, trips[0], isLarge: true),
            const SizedBox(height: 20),
            const Text("Other Trips",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: trips.length - 1,
                itemBuilder: (context, index) {
                  return _buildTripCard(context, trips[index + 1]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTrip = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTripPage()),
          );
          if (newTrip != null) {
            _addNewTrip(newTrip);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip,
      {bool isLarge = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripDetailsPage(trip: trip)),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip["destination"]!,
                style: TextStyle(
                    fontSize: isLarge ? 22 : 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text("Date: ${trip["date"]}"),
              Text("Duration: ${trip["duration"]}"),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTripPage extends StatefulWidget {
  @override
  _AddTripPageState createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _vibeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _activitiesController = TextEditingController();
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

  void _saveTrip() {
    if (_formKey.currentState!.validate()) {
      final newTrip = {
        "destination": _destinationController.text,
        "date": _dateController.text,
        "duration": _durationController.text,
        "name": _nameController.text,
        "image": _image?.path,
        "friends": [],
        "start_date": _dateController.text,
        "end_date": "", // Can be updated later
        "vibe": _vibeController.text,
        "location": _locationController.text,
        "description": _descriptionController.text,
        "comments": _commentsController.text,
        "activities": _activitiesController.text.split(","),
      };
      Navigator.pop(context, newTrip);
    }
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
