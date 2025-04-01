import 'dart:io';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/itinerary.dart';
import '../models/user.dart';
import '../models/accommodation.dart';
import '../models/flight.dart';
import '../models/activity.dart';
import '../models/packing_list.dart';
import '../models/notification.dart';
import '../models/view_option.dart';
import 'dart:convert';
import 'dart:math';
import '../services/firebase_service.dart'; // Import FirebaseService to sync with Firebase

class DatabaseHelper {
  // Private constructor to prevent instantiation
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  static const _dbVersion = 1;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // Getter for the database. It initialises the database if it's null.
  Future<Database> get database async {
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

    // Debug: Delete the database before creating it (for testing purposes)
    if (await File(dbPath).exists()) {
      print('Deleting existing database...');
      await deleteDatabase(dbPath);
    }

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      password: password,
      onOpen: _onOpen, // Enable foreign key support
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
      title TEXT,
      userId INTEGER,
      FOREIGN KEY (userId) REFERENCES user(id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
      CREATE TABLE accommodation(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
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
  Future<int> insertUser(User user) async {
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
    Database db = await instance.database;
    return await db.insert('itinerary', itinerary.toMap());
  }

  // Insert a new accommodation into the 'accommodation' table
  Future<int> insertAccommodation(Accommodation accommodation) async {
    Database db = await instance.database;
    return await db.insert('accommodation', accommodation.toMap());
  }

  // Insert a new flight into the 'flight' table
  Future<int> insertFlight(Flight flight) async {
    Database db = await instance.database;
    return await db.insert('flight', flight.toMap());
  }

  // Insert a new activity into the 'activity' table
  Future<int> insertActivity(Activity activity) async {
    Database db = await instance.database;
    return await db.insert('activity', activity.toMap());
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
  Future<List<Map<String, dynamic>>> loadItineraries() async {
    Database db = await instance.database;
    return await db.query('itinerary');
  }

  // Load all accommodations
  Future<List<Map<String, dynamic>>> loadAccommodations() async {
    Database db = await instance.database;
    return await db.query('accommodation');
  }

  // Load all flights
  Future<List<Map<String, dynamic>>> loadFlights() async {
    Database db = await instance.database;
    return await db.query('flight');
  }

  // Load all activities
  Future<List<Map<String, dynamic>>> loadActivities() async {
    Database db = await instance.database;
    return await db.query('activity');
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
  Future<void> syncUserDataToFirebase(String userId) async {
    List<Map<String, dynamic>> itineraries = await loadItineraries();
    List<Map<String, dynamic>> accommodations = await loadAccommodations();
    List<Map<String, dynamic>> flights = await loadFlights();
    List<Map<String, dynamic>> activities = await loadActivities();
    List<Map<String, dynamic>> packingList = await loadPackingList();

    FirebaseService firebaseService = FirebaseService();

    await firebaseService.syncItineraries(userId, itineraries);
    await firebaseService.syncAccommodations(userId, accommodations);
    await firebaseService.syncFlights(userId, flights);
    await firebaseService.syncActivities(userId, activities);
    await firebaseService.syncPackingList(userId, packingList);

    print("Data synced to Firebase successfully.");
  }
}
