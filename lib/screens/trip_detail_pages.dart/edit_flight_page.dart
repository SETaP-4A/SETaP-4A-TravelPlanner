import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/widgets/date_time_field.dart';

class EditFlightPage extends StatefulWidget {
  final Flight flight;
  final String docId;
  final bool isViewer;
  final String ownerUid;

  const EditFlightPage(
      {super.key,
      required this.flight,
      required this.docId,
      required this.ownerUid,
      this.isViewer = false});

  @override
  State<EditFlightPage> createState() => _EditFlightPageState();
}

class _EditFlightPageState extends State<EditFlightPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _airlineController;
  late TextEditingController _flightNumberController;
  late TextEditingController _departureDateTimeController;
  late TextEditingController _arrivalDateTimeController;
  late TextEditingController _departureAirportController;
  late TextEditingController _arrivalAirportController;
  late TextEditingController _classTypeController;
  late TextEditingController _seatNumberController;

  @override
  void initState() {
    super.initState();
    final f = widget.flight;
    _airlineController = TextEditingController(text: f.airline);
    _flightNumberController = TextEditingController(text: f.flightNumber);
    _departureDateTimeController =
        TextEditingController(text: f.departureDateTime);
    _arrivalDateTimeController = TextEditingController(text: f.arrivalDateTime);
    _departureAirportController =
        TextEditingController(text: f.departureAirport);
    _arrivalAirportController = TextEditingController(text: f.arrivalAirport);
    _classTypeController = TextEditingController(text: f.classType ?? '');
    _seatNumberController = TextEditingController(text: f.seatNumber ?? '');
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final departure =
        DateTime.tryParse(_departureDateTimeController.text.trim());
    final arrival = DateTime.tryParse(_arrivalDateTimeController.text.trim());

    if (departure != null && arrival != null && departure.isAfter(arrival)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departure must be before arrival.')),
      );
      return;
    }

    final updatedFlight = Flight(
      airline: _airlineController.text.trim(),
      flightNumber: _flightNumberController.text.trim(),
      departureDateTime: _departureDateTimeController.text.trim(),
      arrivalDateTime: _arrivalDateTimeController.text.trim(),
      departureAirport: _departureAirportController.text.trim(),
      arrivalAirport: _arrivalAirportController.text.trim(),
      classType: _classTypeController.text.trim(),
      seatNumber: _seatNumberController.text.trim(),
      itineraryFirestoreId: widget.flight.itineraryFirestoreId,
    );

    try {
      if (kIsWeb) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerUid)
            .collection('itineraries')
            .doc(updatedFlight.itineraryFirestoreId)
            .collection('flights')
            .doc(widget.docId)
            .set(updatedFlight.toMap());
      } else {
        // ✅ Sync Firestore even for Android
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerUid)
            .collection('itineraries')
            .doc(updatedFlight.itineraryFirestoreId)
            .collection('flights')
            .doc(widget.docId)
            .set(updatedFlight.toMap());

        await DatabaseHelper.instance.insertFlight(updatedFlight);
      }

      Navigator.pop(context, 'updated');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update flight: $e")),
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
      appBar: AppBar(title: const Text('Edit Flight')),
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
