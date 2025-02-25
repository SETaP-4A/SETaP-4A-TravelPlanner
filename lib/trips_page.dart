import 'package:flutter/material.dart';

class TripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFBCD8C1)),
      child: Card(
        color: Color.fromARGB(255, 223, 211, 151),
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
              SizedBox(
                height: 10,
              ),
              Text('Destination: Bangkok, Thailand'),
              Text('Date: June 1st, 2025'),
              Text('Duration: 74 days'),
            ],
          ),
        ),
      ),
    ));
  }
}
