import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:setap4a/models/user.dart' as app_models;
import 'package:setap4a/services/auth_service.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/itinerary.dart';
import '../models/accommodation.dart';
import '../models/flight.dart';
import '../models/activity.dart';
import '../models/packing_list.dart';
import '../models/notification.dart';
import '../models/view_option.dart';
import 'dart:convert';
import 'dart:math';
import '../services/firebase_service.dart'; // Import FirebaseService to sync with Firebase
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  // Private constructor to prevent instantiation
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  static const _dbVersion = 2;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Getter for the database. It initialises the database if it's null.
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError("SQLite is not supported on Web.");
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialises the database by providing the path and version.
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'app_database.db');

    String? password = await _secureStorage.read(key: 'db_password');
    if (password == null) {
      password = _generateSecurePassword();
      await _secureStorage.write(key: 'db_password', value: password);
    }

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: password,
      onOpen: _onOpen,
    );
  }

  // Called when the database is first created.
  Future<void> _onCreate(Database db, int version) async {
    print('Creating tables...');
    await db.execute('''CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      uid TEXT,
      name TEXT,
      email TEXT
    )''');

    await db.execute('''
  CREATE TABLE itinerary(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    firestoreId TEXT,
    title TEXT,
    startDate TEXT,
    endDate TEXT,
    location TEXT,
    description TEXT,
    comments TEXT,
    userId INTEGER,
    ownerUid TEXT,
    collaborators TEXT,
    permission TEXT,
    FOREIGN KEY (userId) REFERENCES user(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
      CREATE TABLE accommodation(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itineraryFirestoreId TEXT,
      name TEXT,
      location TEXT,
      checkInDate TEXT,
      checkOutDate TEXT,
      bookingConfirmation TEXT,
      roomType TEXT,
      pricePerNight REAL,
      facilities TEXT
    )
    ''');

    await db.execute('''CREATE TABLE flight(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itineraryFirestoreId TEXT,
      airline TEXT,
      flightNumber TEXT,
      departureDateTime TEXT,
      arrivalDateTime TEXT,
      departureAirport TEXT,
      arrivalAirport TEXT,
      classType TEXT,
      seatNumber TEXT
    )''');

    await db.execute('''CREATE TABLE activity(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itineraryFirestoreId TEXT,
      name TEXT,
      type TEXT,
      location TEXT,
      dateTime TEXT,
      duration TEXT,
      notes TEXT
    )''');

    await db.execute('''CREATE TABLE packing_list(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      itemName TEXT,
      quantity INTEGER,
      category TEXT,
      priority TEXT,
      checked INTEGER
    )''');

    await db.execute('''CREATE TABLE notification(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT,
      device TEXT
    )''');

    await db.execute('''CREATE TABLE view_option(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      viewType TEXT,
      selectedItineraryItem TEXT
    )''');

    print('Tables created successfully.');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE itinerary ADD COLUMN ownerUid TEXT");
      await db.execute("ALTER TABLE itinerary ADD COLUMN collaborators TEXT");
      await db.execute("ALTER TABLE itinerary ADD COLUMN permission TEXT");
    }
  }

  // Enables foreign key constraints on opening the database
  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    print('Foreign keys enabled.');
  }

  // Generates a truly random secure password
  String _generateSecurePassword() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final base64 = base64Url.encode(bytes);
    // Ensure the password is exactly 32 characters long and contains only alphanumeric characters
    return base64.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').substring(0, 32);
  }

  // Insert a new user into the 'user' table
  Future<int> insertUser(app_models.User user) async {
    if (kIsWeb) {
      // You can optionally push user info to Firestore instead here
      print('Skipping user insert: SQLite not supported on web.');
      return -1; // Placeholder ID
    }

    try {
      Database db = await instance.database;
      return await db.insert('user', user.toMap());
    } catch (e) {
      print('Error inserting user: $e');
      rethrow;
    }
  }

  // Insert a new itinerary into the 'itinerary' table
  Future<int> insertItinerary(Itinerary itinerary) async {
    final currentUser = await AuthService.getCurrentLocalUser();
    final firestore = FirebaseFirestore.instance;

    // Step 1: Always insert into Firestore first
    final docRef = await firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('itineraries')
        .add(itinerary.toMap());

    await docRef
        .update({'firestoreId': docRef.id}); // Store Firestore ID in doc

    if (kIsWeb) {
      return -1;
    } else {
      // Step 2: Store Firestore ID in SQLite for mobile
      final itineraryWithId = itinerary.copyWith(firestoreId: docRef.id);
      final db = await instance.database;
      return await db.insert('itinerary', itineraryWithId.toMap());
    }
  }

  // Update an existing itinerary
  Future<int> updateItinerary(Itinerary itinerary) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (kIsWeb) {
      // Web: Firebase only
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(itinerary.firestoreId)
          .set(itinerary.toMap());
      return 1;
    } else {
      // Mobile: update SQLite
      final db = await instance.database;
      final result = await db.update(
        'itinerary',
        itinerary.toMap(),
        where: 'id = ?',
        whereArgs: [itinerary.id],
      );

      // Then sync Firebase
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(itinerary.firestoreId)
          .set(itinerary.toMap());

      return result;
    }
  }

  Future<int> deleteItinerary(Itinerary itinerary) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid == null) {
      print('❌ No logged-in Firebase user found.');
      return 0;
    }

    if (kIsWeb) {
      try {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('itineraries')
            .doc(itinerary.firestoreId)
            .delete();
      } catch (e) {
        print("Failed to delete itinerary from Firestore (Web): $e");
      }
      return 1;
    } else {
      // Delete from SQLite
      final db = await instance.database;
      final result = await db.delete(
        'itinerary',
        where: 'id = ?',
        whereArgs: [itinerary.id],
      );

      // Also delete from Firestore
      try {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('itineraries')
            .doc(itinerary.firestoreId)
            .delete();
      } catch (e) {
        print("Failed to delete itinerary from Firestore (Android): $e");
      }

      return result;
    }
  }

  // Insert a new accommodation into the 'accommodation' table
  Future<int> insertAccommodation(Accommodation accommodation) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (kIsWeb) {
      // Web: save only to Firebase
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(accommodation.itineraryFirestoreId)
          .collection('accommodations')
          .add(accommodation.toMap());

      return -1;
    } else {
      // Android: save to SQLite
      final db = await instance.database;
      final id = await db.insert('accommodation', accommodation.toMap());

      // Sync to Firebase
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(accommodation.itineraryFirestoreId)
          .collection('accommodations')
          .add(accommodation.toMap());

      return id;
    }
  }

  // Insert a new flight into the 'flight' table
  Future<int> insertFlight(Flight flight) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (kIsWeb) {
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(flight.itineraryFirestoreId)
          .collection('flights')
          .add(flight.toMap());

      return -1;
    } else {
      final db = await instance.database;
      final id = await db.insert('flight', flight.toMap());

      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(flight.itineraryFirestoreId)
          .collection('flights')
          .add(flight.toMap());

      return id;
    }
  }

  // Insert a new activity into the 'activity' table
  Future<int> insertActivity(Activity activity) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (kIsWeb) {
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(activity.itineraryFirestoreId)
          .collection('activities')
          .add(activity.toMap());

      return -1;
    } else {
      final db = await instance.database;
      final id = await db.insert('activity', activity.toMap());

      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('itineraries')
          .doc(activity.itineraryFirestoreId)
          .collection('activities')
          .add(activity.toMap());

      return id;
    }
  }

  // Insert a new packing list item into the 'packing_list' table
  Future<int> insertPackingList(PackingList packingList) async {
    Database db = await instance.database;
    return await db.insert('packing_list', packingList.toMap());
  }

  // Insert a new notification into the 'notification' table
  Future<int> insertNotification(Notification notification) async {
    Database db = await instance.database;
    return await db.insert('notification', notification.toMap());
  }

  // Insert a new view option into the 'view_option' table
  Future<int> insertViewOption(ViewOption viewOption) async {
    Database db = await instance.database;
    return await db.insert('view_option', viewOption.toMap());
  }

  // Load all users
  Future<List<Map<String, dynamic>>> loadUsers() async {
    Database db = await instance.database;
    return await db.query('user');
  }

  // Load all itineraries
  Future<List<Map<String, dynamic>>> loadItineraries(int userId) async {
    if (kIsWeb) {
      throw UnsupportedError("SQLite is not supported on Web.");
    }

    final db = await instance.database;
    return await db.query(
      'itinerary',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Load all accommodations
  Future<List<Accommodation>> loadAccommodationsForItinerary(
      String itineraryFirestoreId) async {
    if (kIsWeb) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No authenticated user");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('accommodations')
          .where('itineraryFirestoreId', isEqualTo: itineraryFirestoreId)
          .get();

      return snapshot.docs
          .map((doc) => Accommodation.fromMap(doc.data()))
          .toList();
    } else {
      final db = await instance.database;
      final result = await db.query(
        'accommodation',
        where: 'itineraryFirestoreId = ?',
        whereArgs: [itineraryFirestoreId],
      );
      return result.map((map) => Accommodation.fromMap(map)).toList();
    }
  }

  // Load all flights
  Future<List<Flight>> loadFlightsForItinerary(
      String itineraryFirestoreId) async {
    if (kIsWeb) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No authenticated user");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('flights')
          .where('itineraryFirestoreId', isEqualTo: itineraryFirestoreId)
          .get();

      return snapshot.docs.map((doc) => Flight.fromMap(doc.data())).toList();
    } else {
      final db = await instance.database;
      final result = await db.query(
        'flight',
        where: 'itineraryFirestoreId = ?',
        whereArgs: [itineraryFirestoreId],
      );
      return result.map((map) => Flight.fromMap(map)).toList();
    }
  }

  // Load all activities
  Future<List<Activity>> loadActivitiesForItinerary(
      String itineraryFirestoreId) async {
    if (kIsWeb) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No authenticated user");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('activities')
          .where('itineraryFirestoreId', isEqualTo: itineraryFirestoreId)
          .get();

      return snapshot.docs.map((doc) => Activity.fromMap(doc.data())).toList();
    } else {
      final db = await instance.database;
      final result = await db.query(
        'activity',
        where: 'itineraryFirestoreId = ?',
        whereArgs: [itineraryFirestoreId],
      );
      return result.map((map) => Activity.fromMap(map)).toList();
    }
  }

  // Load all packing list items
  Future<List<Map<String, dynamic>>> loadPackingList() async {
    Database db = await instance.database;
    return await db.query('packing_list');
  }

  // Load all notifications
  Future<List<Map<String, dynamic>>> loadNotifications() async {
    Database db = await instance.database;
    return await db.query('notification');
  }

  // Load all view options
  Future<List<Map<String, dynamic>>> loadViewOptions() async {
    Database db = await instance.database;
    return await db.query('view_option');
  }

  // Sync user data to Firebase from SQLite
  Future<void> syncUserDataToFirebase() async {
    final currentUser = await AuthService.getCurrentLocalUser();
    final firebaseService = FirebaseService();

    // Get all itineraries from local DB
    final itineraryMaps = await loadItineraries(currentUser.id!);
    final itineraries =
        itineraryMaps.map((map) => Itinerary.fromMap(map)).toList();

    await firebaseService.syncItineraries(currentUser.uid, itineraryMaps);

    for (final itinerary in itineraries) {
      final itineraryId = itinerary.firestoreId;
      if (itineraryId == null) continue;

      // Load and sync linked sub-items
      final accommodations = await loadAccommodationsForItinerary(itineraryId);
      final flights = await loadFlightsForItinerary(itineraryId);
      final activities = await loadActivitiesForItinerary(itineraryId);

      await firebaseService.syncAccommodations(currentUser.uid,
          accommodations.cast<Map<String, dynamic>>(), itineraryId);
      await firebaseService.syncFlights(
        currentUser.uid,
        flights.map((f) => f.toMap()).toList(),
        itineraryId,
      );

      await firebaseService.syncActivities(
        currentUser.uid,
        activities.map((a) => a.toMap()).toList(),
        itineraryId,
      );
    }

    // Packing list is not itinerary-scoped (assuming), so sync as usual
    final packingList = await loadPackingList();
    await firebaseService.syncPackingList(currentUser.uid, packingList);

    print("✅ Data synced to Firebase successfully.");
  }
}
