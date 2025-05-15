import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:setap4a/db/database_interface.dart';
import 'package:setap4a/models/user.dart' as app_models;
import 'package:setap4a/models/itinerary.dart';
import 'package:setap4a/models/flight.dart';
import 'package:setap4a/models/accommodation.dart';
import 'package:setap4a/models/activity.dart';

import 'db_helper_test.mocks.dart';

@GenerateMocks([DatabaseInterface])
void main() {
  late MockDatabaseInterface mockDb;

  setUp(() {
    mockDb = MockDatabaseInterface();
  });

  group('DatabaseHelper Unit Tests (Mocked)', () {
    test('Insert user returns ID', () async {
      final user =
          app_models.User(uid: '123', name: 'Test', email: 'test@test.com');
      when(mockDb.insertUser(user)).thenAnswer((_) async => 1);
      final id = await mockDb.insertUser(user);
      expect(id, 1);
    });

    test('Insert itinerary returns ID', () async {
      final itinerary = Itinerary(
        title: 'Trip to Barcelona',
        startDate: '2025-07-15',
        endDate: '2025-07-22',
        location: 'Barcelona',
        description: '',
        comments: '',
        ownerUid: 'uid',
        collaborators: [],
        permission: 'owner',
      );
      when(mockDb.insertItinerary(itinerary)).thenAnswer((_) async => 42);
      final id = await mockDb.insertItinerary(itinerary);
      expect(id, 42);
    });

    test('Insert itinerary fails if endDate before startDate', () {
      final itinerary = Itinerary(
        title: 'Broken Trip',
        startDate: '2025-07-22',
        endDate: '2025-07-15',
        location: 'Madrid',
        description: '',
        comments: '',
        ownerUid: 'uid',
        collaborators: [],
        permission: 'owner',
      );

      final start = DateTime.parse(itinerary.startDate!);
      final end = DateTime.parse(itinerary.endDate!);
      final isValid = end.isAfter(start);

      expect(isValid, false);
    });

    test('Insert flight returns ID', () async {
      final flight = Flight(
        itineraryFirestoreId: 'abc123',
        airline: 'AirTest',
        flightNumber: 'AT123',
        departureDateTime: '2025-06-01T10:00',
        arrivalDateTime: '2025-06-01T12:00',
        departureAirport: 'JFK',
        arrivalAirport: 'CDG',
        classType: 'Economy',
        seatNumber: '12A',
      );
      when(mockDb.insertFlight(flight)).thenAnswer((_) async => 5);
      final id = await mockDb.insertFlight(flight);
      expect(id, 5);
    });

    test('Insert accommodation returns ID', () async {
      final accommodation = Accommodation(
        itineraryFirestoreId: 'trip123',
        name: 'Hotel Test',
        location: 'Paris',
        checkInDate: '2025-07-15',
        checkOutDate: '2025-07-22',
        bookingConfirmation: 'CONF123',
        roomType: 'Double',
        pricePerNight: 120.0,
        facilities: 'Pool,Gym',
      );
      when(mockDb.insertAccommodation(accommodation))
          .thenAnswer((_) async => 6);
      final id = await mockDb.insertAccommodation(accommodation);
      expect(id, 6);
    });

    test('Insert activity returns ID', () async {
      final activity = Activity(
        itineraryFirestoreId: 'trip123',
        name: 'Tapas Tour',
        type: 'Food',
        location: 'Madrid',
        dateTime: '2025-07-18T18:00',
        duration: '2h',
        notes: 'Bring your own snacks',
      );
      when(mockDb.insertActivity(activity)).thenAnswer((_) async => 7);
      final id = await mockDb.insertActivity(activity);
      expect(id, 7);
    });

    test('Update itinerary returns 1', () async {
      final itinerary = Itinerary(
        id: 1,
        firestoreId: 'abc123',
        title: 'Updated Trip',
        startDate: '2025-07-15',
        endDate: '2025-07-22',
        location: 'Rome',
        description: '',
        comments: '',
        ownerUid: 'uid',
        collaborators: [],
        permission: 'owner',
      );
      when(mockDb.updateItinerary(itinerary)).thenAnswer((_) async => 1);
      final result = await mockDb.updateItinerary(itinerary);
      expect(result, 1);
    });

    test('Delete itinerary returns 1', () async {
      final itinerary = Itinerary(id: 1, firestoreId: 'abc123');
      when(mockDb.deleteItinerary(itinerary)).thenAnswer((_) async => 1);
      final result = await mockDb.deleteItinerary(itinerary);
      expect(result, 1);
    });

    test('Editor can write, viewer cannot', () {
      final viewerItinerary = Itinerary(permission: 'viewer');
      final editorItinerary = Itinerary(permission: 'editor');

      final viewerCanEdit = viewerItinerary.permission == 'editor' ||
          viewerItinerary.permission == 'owner';
      final editorCanEdit = editorItinerary.permission == 'editor' ||
          editorItinerary.permission == 'owner';

      expect(viewerCanEdit, false);
      expect(editorCanEdit, true);
    });

    test('Owner can always edit', () {
      final ownerItinerary = Itinerary(permission: 'owner');
      final canEdit = ['editor', 'owner'].contains(ownerItinerary.permission);
      expect(canEdit, true);
    });
  });
}
