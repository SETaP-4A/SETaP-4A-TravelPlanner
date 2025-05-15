import 'package:flutter/material.dart';
import 'trip_pages/trips_page.dart';
import 'friend_pages/friends_page.dart';
import 'explore_pages/explore_page.dart';
import 'user_profile_pages/user_profile_page.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:setap4a/screens/login_screen.dart';

// The main landing page once a user is signed in.
// It uses a navigation drawer to move between main sections of the app.

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode>
      themeNotifier; // Used to toggle light/dark mode
  const HomeScreen({super.key, required this.themeNotifier});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keeps track of the currently selected page (shown in the body)
  Widget currentPage = TripsPage();

  // Method for switching between pages when a drawer item is tapped
  void _navigateTo(Widget page) {
    setState(() {
      currentPage = page;
    });
    Navigator.pop(context); // Close the drawer after navigation
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
          // Logout button in the top-right of the AppBar
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await AuthService().signOut();

              // After logging out, navigate to login screen and remove all previous routes
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
            // Drawer header at the top
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            // Navigation options
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
                Navigator.pushNamed(
                    context, '/settings'); // Navigate using named route
              },
            ),
          ],
        ),
      ),
      body: currentPage, // Show the currently selected page here
    );
  }
}
