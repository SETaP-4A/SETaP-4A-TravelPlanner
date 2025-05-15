import 'package:flutter/foundation.dart';

class Activity {
  final String?
      id; // Optional local identifier, useful for local DBs or UI keys
  final String itineraryFirestoreId; // ID of the trip this activity belongs to
  final String name; // e.g., "Museum Visit"
  final String type; // e.g., "Cultural", "Adventure", "Relaxation"
  final String location;
  final String dateTime; // Stored as String (you might consider DateTime later)
  final String duration; // Can be "2h", "All Day", etc.
  final String notes; // Optional extra details, reminders, etc.

  Activity({
    this.id,
    required this.itineraryFirestoreId,
    required this.name,
    required this.type,
    required this.location,
    required this.dateTime,
    required this.duration,
    required this.notes,
  });

  // Factory to create an Activity from a Map (e.g. from Firebase or SQLite)
  factory Activity.fromMap(Map<String, dynamic> map, {String? id}) {
    return Activity(
      id: id,
      itineraryFirestoreId: map['itineraryFirestoreId'],
      name: map['name'] ?? '', // Use empty strings as fallback to avoid nulls
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      dateTime: map['dateTime'] ?? '',
      duration: map['duration'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  // Converts the Activity object into a Map to store in a database
  Map<String, dynamic> toMap() {
    final map = {
      'itineraryFirestoreId': itineraryFirestoreId,
      'name': name,
      'type': type,
      'location': location,
      'dateTime': dateTime,
      'duration': duration,
      'notes': notes,
    };

    debugPrint(
        "Activity toMap: $map"); // Handy for logging activity saves/updates
    return map;
  }
}
