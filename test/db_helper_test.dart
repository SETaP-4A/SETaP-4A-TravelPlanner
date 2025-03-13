import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi for local testing (no VM)
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/models/activity.dart';
import 'package:setap4a/models/packing_list.dart';
import 'package:setap4a/models/notification.dart';
import 'package:setap4a/models/view_option.dart';
import 'package:setap4a/models/user.dart';

void main() {
  // Initialize sqflite for tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    late DatabaseHelper databaseHelper;

    setUp(() async {
      databaseHelper = DatabaseHelper.instance;
      await databaseHelper.database;
    });

    test('Insert an itinerary', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('user', {'id': 1, 'name': 'Test User'});
      final itineraryId = await db.insert('itinerary', {
        'title': 'Test Itinerary',
        'userId': 1,
      });
      expect(itineraryId, isNonZero);
    });

    test('Insert a user', () async {
      final user = User(name: 'John Doe');
      final id = await databaseHelper.insertUser(user);
      expect(id, isNotNull);
    });

    test('Insert an accommodation', () async {
      final accommodation = Accommodation(
        name: 'Test Hotel',
        location: 'Test Location',
        checkInDate: '2025-04-01',
        checkOutDate: '2025-04-07',
        bookingConfirmation: 'ABC123',
        roomType: 'Single Room',
        pricePerNight: '100.0',
        facilities: 'Free Wi-Fi, Pool',
      );
      final id = await databaseHelper.insertAccommodation(accommodation);
      expect(id, isNotNull);
    });

    test('Insert a flight', () async {
      final flight = Flight(
        airline: 'Test Airlines',
        flightNumber: 'TA123',
        departureDateTime: '2025-04-01 10:00',
        arrivalDateTime: '2025-04-01 12:00',
        departureAirport: 'Test Airport',
        arrivalAirport: 'Test Destination',
        classType: 'Economy',
        seatNumber: '12A',
      );
      final id = await databaseHelper.insertFlight(flight);
      expect(id, isNotNull);
    });

    test('Insert an activity', () async {
      final activity = Activity(
        name: 'Test Activity',
        type: 'Tour',
        location: 'Test Location',
        dateTime: '2025-04-01 15:00',
        duration: '2 hours',
        notes: 'Bring sunscreen',
      );
      final id = await databaseHelper.insertActivity(activity);
      expect(id, isNotNull);
    });

    test('Insert a packing list item', () async {
      final packingListItem = PackingList(
        itemName: 'Shirt',
        quantity: '2',
        category: 'Clothing',
        priority: 'High',
        checked: 'Not checked',
      );
      final id = await databaseHelper.insertPackingList(packingListItem);
      expect(id, isNotNull);
    });

    test('Insert a notification', () async {
      final notification = Notification(
        type: 'Upcoming flight',
        device: 'Mobile phone',
      );
      final id = await databaseHelper.insertNotification(notification);
      expect(id, isNotNull);
    });

    test('Insert a view option', () async {
      final viewOption = ViewOption(
        viewType: 'Calendar',
        selectedItineraryItem: 'Flight details',
      );
      final id = await databaseHelper.insertViewOption(viewOption);
      expect(id, isNotNull);
    });

    test('Load itineraries', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('user', {'id': 1, 'name': 'Test User'});
      await db.insert('itinerary', {'title': 'Test Itinerary', 'userId': 1});
      final itineraries = await db.query('itinerary');
      expect(itineraries, isNotEmpty);
    });

    test('Load accommodations', () async {
      final accommodation = Accommodation(
        name: 'Test Hotel',
        location: 'Test Location',
        checkInDate: '2025-04-01',
        checkOutDate: '2025-04-07',
        bookingConfirmation: 'ABC123',
        roomType: 'Single Room',
        pricePerNight: '100.0',
        facilities: 'Free Wi-Fi, Pool',
      );
      await databaseHelper.insertAccommodation(accommodation);
      final accommodations = await databaseHelper.loadAccommodations();
      expect(accommodations, isNotEmpty);
    });

    test('Load flights', () async {
      final flight = Flight(
        airline: 'Test Airlines',
        flightNumber: 'TA123',
        departureDateTime: '2025-04-01 10:00',
        arrivalDateTime: '2025-04-01 12:00',
        departureAirport: 'Test Airport',
        arrivalAirport: 'Test Destination',
        classType: 'Economy',
        seatNumber: '12A',
      );
      await databaseHelper.insertFlight(flight);
      final flights = await databaseHelper.loadFlights();
      expect(flights, isNotEmpty);
    });

    test('Prevent inserting itinerary with invalid userId', () async {
      final db = await DatabaseHelper.instance.database;
      expect(
        () async => await db
            .insert('itinerary', {'title': 'Invalid Itinerary', 'userId': 99}),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Update an itinerary title', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('user', {'id': 1, 'name': 'Test User'});
      final itineraryId =
          await db.insert('itinerary', {'title': 'Old Title', 'userId': 1});
      await db.update('itinerary', {'title': 'New Title'},
          where: 'id = ?', whereArgs: [itineraryId]);
      final updated = await db
          .query('itinerary', where: 'id = ?', whereArgs: [itineraryId]);
      expect(updated.first['title'], 'New Title');
    });

    tearDown(() async {
      final db = await databaseHelper.database;
      await db.delete('itinerary');
      await db.delete('user');
      await db.delete('accommodation');
      await db.delete('flight');
      await db.delete('activity');
      await db.delete('packing_list');
      await db.delete('notification');
      await db.delete('view_option');
    });
  });
}
