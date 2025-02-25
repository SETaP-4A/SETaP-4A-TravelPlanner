import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi for local testing (no VM)
import 'package:se_cw/db/database_helper.dart'; // Import the DatabaseHelper for DB operations
import 'package:se_cw/models/itinerary.dart'; // Import the Itinerary model

void main() {
  // Make sure to initialize sqflite correctly for tests (since we're not using the VM version)
  sqfliteFfiInit();
  databaseFactory =
      databaseFactoryFfi; // Use the FFI version of the database factory

  group('DatabaseHelper Tests', () {
    late DatabaseHelper databaseHelper;

    // This runs before each test to set up the initial environment
    setUp(() async {
      databaseHelper = DatabaseHelper.instance;
      await databaseHelper.database; // Initialize the database before each test
    });

    // Test for inserting an itinerary into the database
    test('Insert an itinerary', () async {
      final itinerary = Itinerary(
        title: 'Test Itinerary',
        userId: 1, // Assuming user ID 1 exists
      );
      final id = await databaseHelper.insertItinerary(itinerary);
      expect(id, isNotNull); // ID should be returned when insert is successful
    });

    // Test for loading itineraries from the database
    test('Load itineraries', () async {
      // Insert a sample itinerary before loading
      final itinerary = Itinerary(
        title: 'Test Itinerary',
        userId: 1,
      );
      await databaseHelper.insertItinerary(itinerary);

      // Retrieve and print itineraries
      final itineraries = await databaseHelper.loadItineraries();
      print('Itineraries loaded: $itineraries'); // Debug print

      // Assert that the itineraries list is not empty
      expect(itineraries, isNotEmpty);
    });

    // This runs after each test to clean up if necessary
    tearDown(() async {
      final db = await databaseHelper.database;
      await db.delete('itinerary');
      await db.delete('user');
    });
  });
}
