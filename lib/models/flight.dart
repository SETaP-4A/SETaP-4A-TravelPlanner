import 'package:flutter/foundation.dart';

class Flight {
  final String? id; // Local ID, used for SQLite or list handling
  final String?
      itineraryFirestoreId; // Firestore trip reference, nullable in case you're only using local data
  final String airline; // e.g., "British Airways"
  final String flightNumber; // e.g., "BA123"
  final String departureDateTime; // Stored as a formatted string
  final String arrivalDateTime;
  final String departureAirport; // Airport codes or names (e.g. "LHR")
  final String arrivalAirport;
  final String? classType; // Optional (e.g., Economy, Business)
  final String? seatNumber; // Optional (e.g., "12A")

  Flight({
    this.id,
    this.itineraryFirestoreId,
    required this.airline,
    required this.flightNumber,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.departureAirport,
    required this.arrivalAirport,
    this.classType,
    this.seatNumber,
  });

  // Turns this object into a Map for saving to Firestore or local DB
  Map<String, dynamic> toMap() {
    final map = {
      'airline': airline,
      'flightNumber': flightNumber,
      'departureDateTime': departureDateTime,
      'arrivalDateTime': arrivalDateTime,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'classType': classType,
      'seatNumber': seatNumber,
      'itineraryFirestoreId': itineraryFirestoreId,
    };

    debugPrint("Flight toMap: $map"); // Good for verifying what's being saved
    return map;
  }

  // Builds a Flight from a Map (e.g., from Firebase or local DB)
  factory Flight.fromMap(Map<String, dynamic> map, {String? id}) {
    return Flight(
      id: id,
      itineraryFirestoreId: map['itineraryFirestoreId']
          ?.toString(), // Just in case Firestore sends int/num
      airline: map['airline']?.toString() ??
          '', // Safe fallback to avoid null crashes
      flightNumber: map['flightNumber']?.toString() ?? '',
      departureDateTime: map['departureDateTime']?.toString() ?? '',
      arrivalDateTime: map['arrivalDateTime']?.toString() ?? '',
      departureAirport: map['departureAirport']?.toString() ?? '',
      arrivalAirport: map['arrivalAirport']?.toString() ?? '',
      classType: map['classType']?.toString(),
      seatNumber: map['seatNumber']?.toString(),
    );
  }
}
