import 'package:attempt1/account_page.dart';
import 'package:flutter/material.dart';
import 'trips_page.dart';
import 'friends_page.dart';
import 'explore_page.dart';

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
            Row(
              children: [
                Icon(Icons.flight_takeoff),
                SizedBox(width: 10),
                Text('Travel App'),
              ],
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () => _navigateTo(AccountPage()),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.card_travel),
              title: Text('Trips'),
              onTap: () => _navigateTo(TripsPage()),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Friends'),
              onTap: () => _navigateTo(FriendsPage()),
            ),
            ListTile(
              leading: Icon(Icons.explore),
              title: Text('Explore'),
              onTap: () => _navigateTo(ExplorePage()),
            ),
          ],
        ),
      ),
      body: _currentPage,
    );
  }
}
