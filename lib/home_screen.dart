import 'package:flutter/material.dart';
import 'trips_page.dart';
import 'friends_page.dart';
import 'explore_page.dart';
import 'account_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _currentPage = TripsPage();

  void _navigateTo(Widget page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.flight_takeoff),
                SizedBox(width: 10),
                Text('Travel App'),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => _navigateTo(AccountPage()),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.card_travel),
              title: const Text('Trips'),
              onTap: () => _navigateTo(TripsPage()),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Friends'),
              onTap: () => _navigateTo(FriendsPage()),
            ),
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('Explore'),
              onTap: () => _navigateTo(ExplorePage()),
            ),
          ],
        ),
      ),
      body: _currentPage,
    );
  }
}
