import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ItineraryScreen extends StatefulWidget {
  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  List<Map<String, dynamic>> _itineraries = [];

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  // Method to load itineraries from the database
  Future<void> _loadItineraries() async {
    final itineraries = await DatabaseHelper.instance.loadItineraries();
    setState(() {
      _itineraries = itineraries; // Store the results in _itineraries
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerary Screen'),
      ),
      body: ListView.builder(
        itemCount: _itineraries.length,
        itemBuilder: (context, index) {
          final itinerary = _itineraries[index];
          return ListTile(
            title: Text(itinerary['title'] ?? 'No title'),
          );
        },
      ),
    );
  }
}
