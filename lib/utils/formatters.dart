import 'package:intl/intl.dart';

String formatFlight(Map<String, dynamic> flight) {
  final airline = flight['airline'] ?? '';
  final number = flight['flightNumber'] ?? '';
  final from = flight['departureAirport'] ?? '';
  final to = flight['arrivalAirport'] ?? '';
  final timeRaw = flight['departureDateTime'] ?? '';

  late final String dateFormatted;

  try {
    final parsed = DateFormat('MMM dd, yyyy HH:mm').parse(timeRaw);
    dateFormatted = DateFormat('MMM dd, yyyy • HH:mm').format(parsed);
  } catch (_) {
    dateFormatted = timeRaw;
  }

  return "$airline • Flight $number\n$from → $to\n$dateFormatted";
}

String formatAccommodation(Map<String, dynamic> accommodation) {
  final name = accommodation['name'] ?? '';
  final location = accommodation['location'] ?? '';
  final checkInRaw = accommodation['checkInDate'] ?? '';
  final checkOutRaw = accommodation['checkOutDate'] ?? '';

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

String formatActivity(Map<String, dynamic> activity) {
  final name = activity['name'] ?? '';
  final location = activity['location'] ?? '';
  final dateTime = activity['dateTime'] ?? '';

  String result;

  try {
    final parsedDate = DateFormat('MMMM d, yyyy HH:mm').parse(dateTime);
    final formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
    final formattedTime = DateFormat('HH:mm').format(parsedDate);
    result = "$name \n$location\n$formattedDate at $formattedTime";
  } catch (_) {
    result = "$name \n$location\n$dateTime"; // fallback
  }

  return result;
}
