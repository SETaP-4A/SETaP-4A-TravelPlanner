import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:setap4a/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test that app directs to login page", (WidgetTester tester) async {
    app.main(); // Launches the app
    await tester.pumpAndSettle(Duration(minutes: 1)); // Waits for the app to settle. Set to 1 minute to ensure app is fully loaded.

    // Checks to ensure theres an option to continue with Google
    expect(find.text("Continue with Google"), findsOneWidget);
    // Checks to ensure theres the "Login" title, and a "Login button"
    expect(find.text("Login"), findsAtLeastNWidgets(2));
  });
}