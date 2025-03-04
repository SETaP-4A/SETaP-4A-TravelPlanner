import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/itinerary.dart';
import '../models/user.dart';

class DatabaseHelper {
  // Private constructor to prevent instantiation
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

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
    return openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  // Creates the necessary tables when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    // Create a 'user' table to store user data
    await db.execute('''
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // Create an 'itinerary' table that links to the 'user' table via userId
    await db.execute('''
      CREATE TABLE itinerary(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES user (id)
      )
    ''');
  }

  // Insert a new user into the 'user' table
  Future<int> insertUser(User user) async {
    try {
      Database db = await instance.database; // Get the database instance
      return await db.insert('user', user.toMap()); // Insert the user data
    } catch (e) {
      print('Error inserting user: $e'); // Print the error message if it occurs
      rethrow;
    }
  }

  // Insert a new itinerary into the 'itinerary' table
  Future<int> insertItinerary(Itinerary itinerary) async {
    try {
      Database db = await instance.database; // Get the database instance
      return await db.insert(
          'itinerary', itinerary.toMap()); // Insert the itinerary data
    } catch (e) {
      print(
          'Error inserting itinerary: $e'); // Print the error message if it occurs
      rethrow;
    }
  }

  // Load all itineraries from the 'itinerary' table
  Future<List<Map<String, dynamic>>> loadItineraries() async {
    try {
      Database db = await instance.database; // Get the database instance
      return await db
          .query('itinerary'); // Return all itineraries from the table
    } catch (e) {
      print(
          'Error loading itineraries: $e'); // Print the error message if it occurs
      rethrow;
    }
  }
}
