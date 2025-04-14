import 'package:flutter/material.dart';
import 'trip_pages/trips_page.dart';
import 'friend_pages/friends_page.dart';
import 'explore_pages/explore_page.dart';
import 'user_profile_pages/user_profile_page.dart';
// To format and compare dates

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget currentPage = TripsPage();

  void _navigateTo(Widget page) {
    setState(() {
      currentPage = page;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Travel App',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: Text('Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
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
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Account'),
                onTap: () => _navigateTo(AccountPage()),
              ),
            ],
          ),
        ),
        body: currentPage);
  }
}
