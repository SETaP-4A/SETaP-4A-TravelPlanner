// main.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(TravelApp());
}

class TravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blueGrey[50],
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold), // Replaces headline6
          bodyLarge: TextStyle(fontSize: 18), // Replaces bodyText12
        ),
      ),
      home: HomeScreen(),
    );
  }
}
