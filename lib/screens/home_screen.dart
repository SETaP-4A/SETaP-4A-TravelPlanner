import 'package:flutter/material.dart';
import 'itinerary_screen.dart'; // Import the Itinerary Screen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'), // Title of the app bar
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the Itinerary Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ItineraryScreen()),
            );
          },
          child: Text('Go to Itinerary'), // Button text
        ),
      ),
    );
  }
}
