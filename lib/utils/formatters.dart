import 'package:intl/intl.dart';

/// Formats flight details into a readable string for display.
///
/// Example output:
/// "British Airways • Flight BA123
/// LHR → JFK
/// Apr 25, 2025 • 15:30"
String formatFlight(Map<String, dynamic> flight) {
  final airline = flight['airline'] ?? '';
  final number = flight['flightNumber'] ?? '';
  final from = flight['departureAirport'] ?? '';
  final to = flight['arrivalAirport'] ?? '';
  final timeRaw = flight['departureDateTime'] ?? '';

  late final String dateFormatted;

  try {
    // Try to parse the raw date string and reformat it
    final parsed = DateFormat('MMM dd, yyyy HH:mm').parse(timeRaw);
    dateFormatted = DateFormat('MMM dd, yyyy • HH:mm').format(parsed);
  } catch (_) {
    // If parsing fails, fallback to the raw string
    dateFormatted = timeRaw;
  }

  return "$airline • Flight $number\n$from → $to\n$dateFormatted";
}

/// Formats accommodation details into a readable string.
///
/// Example output:
/// "Marriott Hotel
/// Paris
/// Apr 24, 2025 → Apr 27, 2025"
String formatAccommodation(Map<String, dynamic> accommodation) {
  final name = accommodation['name'] ?? '';
  final location = accommodation['location'] ?? '';
  final checkInRaw = accommodation['checkInDate'] ?? '';
  final checkOutRaw = accommodation['checkOutDate'] ?? '';

  // Helper function to format dates or fallback to raw string
  String formatDate(String raw) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(raw);
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  final checkIn = formatDate(checkInRaw);
  final checkOut = formatDate(checkOutRaw);

  return "$name\n$location\n$checkIn → $checkOut";
}

/// Formats activity details into a readable string with time if available.
///
/// Example output:
/// "Museum Visit
/// Rome
/// Apr 26, 2025 at 14:00"
String formatActivity(Map<String, dynamic> activity) {
  final name = activity['name'] ?? '';
  final location = activity['location'] ?? '';
  final dateTime = activity['dateTime'] ?? '';

  String result;

  try {
    // Try to parse and format both date and time
    final parsedDate = DateFormat('MMMM d, yyyy HH:mm').parse(dateTime);
    final formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
    final formattedTime = DateFormat('HH:mm').format(parsedDate);
    result = "$name \n$location\n$formattedDate at $formattedTime";
  } catch (_) {
    // If parsing fails, fallback to displaying the raw dateTime
    result = "$name \n$location\n$dateTime";
  }

  return result;
}
