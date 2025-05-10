class Flight {
  final String? id;
  final String? itineraryFirestoreId;
  final String airline;
  final String flightNumber;
  final String departureDateTime;
  final String arrivalDateTime;
  final String departureAirport;
  final String arrivalAirport;
  final String? classType;
  final String? seatNumber;

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

  // Convert a Flight object into a Map
  Map<String, dynamic> toMap() {
    return {
      'itineraryFirestoreId': itineraryFirestoreId,
      'airline': airline,
      'flightNumber': flightNumber,
      'departureDateTime': departureDateTime,
      'arrivalDateTime': arrivalDateTime,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'classType': classType,
      'seatNumber': seatNumber,
    };
  }

  // Convert a Map into a Flight object
  factory Flight.fromMap(Map<String, dynamic> map, {String? id}) {
    return Flight(
      id: id,
      itineraryFirestoreId: map['itineraryFirestoreId']?.toString(),
      airline: map['airline']?.toString() ?? '',
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
