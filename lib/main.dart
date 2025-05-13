import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:setap4a/screens/home_screen.dart';
import 'package:setap4a/screens/login_screen.dart';
import 'package:setap4a/screens/user_profile_pages/settings_page.dart';
import 'firebase_options.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Travel Planner',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue, brightness: Brightness.light),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue, brightness: Brightness.dark),
          ),
          routes: {
            '/settings': (context) =>
                SettingsPage(themeNotifier: themeNotifier),
          },
          home: user != null
              ? HomeScreen(themeNotifier: themeNotifier)
              : LoginScreen(),
        );
      },
    );
  }
}
