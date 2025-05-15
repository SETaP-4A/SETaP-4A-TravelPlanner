import 'package:flutter/foundation.dart';

class Accommodation {
  final String? id; // Optional local ID (e.g. for SQLite or UI list keys)
  final String
      itineraryFirestoreId; // Links this accommodation to a specific trip
  final String name;
  final String location;
  final String
      checkInDate; // Stored as String for simplicity (you could consider DateTime later)
  final String checkOutDate;
  final String bookingConfirmation;
  final String roomType;
  final double pricePerNight;
  final String facilities; // Could be comma-separated or structured if needed

  Accommodation({
    this.id,
    required this.itineraryFirestoreId,
    required this.name,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingConfirmation,
    required this.roomType,
    required this.pricePerNight,
    required this.facilities,
  });

  // Converts this object into a Map for SQLite or Firebase
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'location': location,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'bookingConfirmation': bookingConfirmation,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'facilities': facilities,
      'itineraryFirestoreId': itineraryFirestoreId,
    };

    debugPrint(
        "Accommodation toMap: $map"); // Helpful for debugging form submissions etc.
    return map;
  }

  // Factory constructor to build an Accommodation object from a Map
  factory Accommodation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Accommodation(
      id: id, // Optional manual override of ID (useful for local databases)
      itineraryFirestoreId: map['itineraryFirestoreId'],
      name: map['name'],
      location: map['location'],
      checkInDate: map['checkInDate'],
      checkOutDate: map['checkOutDate'],
      bookingConfirmation: map['bookingConfirmation'],
      roomType: map['roomType'],
      pricePerNight: () {
        final raw = map['pricePerNight'];

        // Make sure we can handle both double and string types gracefully
        if (raw is num) return raw.toDouble();

        if (raw is String) {
          final parsed = double.tryParse(raw);
          if (parsed != null) return parsed;

          // Log this if the value isn't valid so it doesn't silently break
          print("Invalid pricePerNight: $raw");
        }

        // Default fallback to 0.0 if parsing fails
        return 0.0;
      }(),
      facilities: map['facilities'],
    );
  }
}
