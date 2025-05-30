import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:setap4a/main.dart' as app;

// Function to wait for a widget to appear to ensure that the app is fully loaded
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 60),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(interval);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw Exception('Widget not found within ${timeout.inSeconds} seconds: $finder');
}

// launches app to the expected login screen
Future<void> launchApp(WidgetTester tester) async {
  app.main();
  await tester.pump(); 
  await waitForWidget(tester, find.text("Continue with Google"));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group("Itinerary Management Tests", () {
    testWidgets("Test login screen shows up", (tester) async {
      await launchApp(tester); // app launch + wait until it's ready
    
      // Checks to ensure theres the "Login" title, and a "Login" button
      expect(find.text("Login"), findsAtLeastNWidgets(2));
    });
    
    testWidgets("Can Successfully login", (tester) async {
      await launchApp(tester); // app launch + wait until it's ready
      // Enter email and password, then tap the login button
      await tester.enterText(find.bySemanticsLabel('Email'), "kevin@test.com");
      await tester.enterText(find.bySemanticsLabel('Password'), "Test123!");
      await tester.tap(find.byKey(const Key("loginButton")));
      await tester.pumpAndSettle();
      // Wait for next screen to load
      await waitForWidget(tester, find.text("Travel App"));
      // Checks to ensure the "Upcoming Trips" section is present
      expect(find.text("Upcoming Trips"), findsOneWidget);
    });

  });
}
