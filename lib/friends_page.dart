import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Friends List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('John Doe - Traveling to Rome'),
          Text('Jane Smith - Exploring Thailand'),
          Text('Alice Johnson - Backpacking in Peru'),
        ],
      ),
    );
  }
}
