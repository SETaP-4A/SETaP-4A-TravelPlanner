// main.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'account_page.dart';

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
        textTheme: const TextTheme(
          headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 18),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
