import 'package:flutter/material.dart';
import 'trip_pages/trips_page.dart';
import 'friend_pages/friends_page.dart';
import 'explore_pages/explore_page.dart';
import 'user_profile_pages/user_profile_page.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:setap4a/screens/login_screen.dart';

// To format and compare dates

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const HomeScreen({super.key, required this.themeNotifier});

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
          title: const Text(
            'Travel App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
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
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
        body: currentPage);
  }
}
