import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:setap4a/screens/home_screen.dart';
import 'package:setap4a/screens/login_screen.dart';
import 'package:setap4a/screens/user_profile_pages/settings_page.dart';
import 'firebase_options.dart';

// Global notifier to manage app's theme mode (light/dark/system)
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  // Ensure Flutter widget binding is initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app, passing the theme notifier
  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    // Check if user is already signed in via FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    // Listen to theme mode changes and rebuild accordingly
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Travel Planner',
          debugShowCheckedModeBanner: false, // Disable debug banner
          themeMode: mode, // Apply current theme mode
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          // Define named routes for navigation
          routes: {
            '/settings': (context) =>
                SettingsPage(themeNotifier: themeNotifier),
          },
          // Show HomeScreen if user logged in, else show LoginScreen
          home: user != null
              ? HomeScreen(themeNotifier: themeNotifier)
              : LoginScreen(),
        );
      },
    );
  }
}
