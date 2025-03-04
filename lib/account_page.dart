import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle, size: 80, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                'User Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Name: John Doe'),
              Text('Email: johndoe@example.com'),
              Text('Membership: Premium'),
            ],
          ),
        ),
      ),
    );
  }
}
