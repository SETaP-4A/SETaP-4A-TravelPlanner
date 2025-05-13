import 'package:flutter/foundation.dart';

class Activity {
  final String? id;
  final String itineraryFirestoreId;
  final String name;
  final String type;
  final String location;
  final String dateTime;
  final String duration;
  final String notes;

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

  factory Activity.fromMap(Map<String, dynamic> map, {String? id}) {
    return Activity(
      id: id,
      itineraryFirestoreId: map['itineraryFirestoreId'],
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      dateTime: map['dateTime'] ?? '',
      duration: map['duration'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

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
    debugPrint("🎯 Activity toMap: $map");
    return map;
  }
}
