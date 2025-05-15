import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:setap4a/screens/trip_pages/trip_details_page.dart';
import 'package:setap4a/widgets/date_time_field.dart';

class AddFlightPage extends StatefulWidget {
  final String itineraryFirestoreId;
  final String? ownerUid;

  const AddFlightPage(
      {super.key, required this.itineraryFirestoreId, required this.ownerUid});

  @override
  State<AddFlightPage> createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _airlineController = TextEditingController();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureDateTimeController =
      TextEditingController();
  final TextEditingController _arrivalDateTimeController =
      TextEditingController();
  final TextEditingController _departureAirportController =
      TextEditingController();
  final TextEditingController _arrivalAirportController =
      TextEditingController();
  final TextEditingController _classTypeController = TextEditingController();
  final TextEditingController _seatNumberController = TextEditingController();

  void _saveFlight() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ No user is signed in.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not signed in.')),
      );
      return;
    }

    // Validates that departure is before arrival
    final departure =
        DateTime.tryParse(_departureDateTimeController.text.trim());
    final arrival = DateTime.tryParse(_arrivalDateTimeController.text.trim());

    if (departure != null && arrival != null && departure.isAfter(arrival)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departure must be before arrival.')),
      );
      return;
    }

    final newFlight = Flight(
      airline: _airlineController.text.trim(),
      flightNumber: _flightNumberController.text.trim(),
      departureDateTime: _departureDateTimeController.text.trim(),
      arrivalDateTime: _arrivalDateTimeController.text.trim(),
      departureAirport: _departureAirportController.text.trim(),
      arrivalAirport: _arrivalAirportController.text.trim(),
      classType: _classTypeController.text.trim(),
      seatNumber: _seatNumberController.text.trim(),
      itineraryFirestoreId: widget.itineraryFirestoreId,
    );

    try {
      if (kIsWeb) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerUid)
            .collection('itineraries')
            .doc(widget.itineraryFirestoreId)
            .collection('flights')
            .add(newFlight.toMap());
      } else {
        await DatabaseHelper.instance.insertFlight(newFlight);
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
      print("❌ Failed to save flight: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save flight: $e")),
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
      appBar: AppBar(title: const Text('Add Flight')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField('Airline', _airlineController),
                _buildField('Flight Number', _flightNumberController),
                DateTimeField(
                  controller: _departureDateTimeController,
                  label: 'Departure Date & Time',
                  isRequired: true,
                ),
                DateTimeField(
                  controller: _arrivalDateTimeController,
                  label: 'Arrival Date & Time',
                  isRequired: true,
                ),
                _buildField('Departure Airport', _departureAirportController),
                _buildField('Arrival Airport', _arrivalAirportController),
                _buildField('Class Type', _classTypeController, optional: true),
                _buildField('Seat Number', _seatNumberController,
                    optional: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveFlight,
                  child: const Text('Save Flight'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool optional = false}) {
    final themeColor = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (!optional && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 16,
                color: themeColor,
              ),
              children: optional
                  ? []
                  : const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      )
                    ],
            ),
          ),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}
