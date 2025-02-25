import 'package:flutter/material.dart';

class TripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upcoming Trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Destination: Paris, France'),
              Text('Date: March 15, 2025'),
              Text('Duration: 7 days'),
            ],
          ),
        ),
      ),
    );
  }
}
