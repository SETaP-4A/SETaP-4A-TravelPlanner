import 'dart:ui';

import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('name'),
          actions: [IconButton(onPressed: null, icon: Icon(Icons.settings))],
          automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 16),
            Text(
              'name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'trip',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 10,
                  width: MediaQuery.of(context).size.width / 5 * 4,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 228, 227, 227))),
                )),
          ],
        ),
      ),
    );
  }
}
