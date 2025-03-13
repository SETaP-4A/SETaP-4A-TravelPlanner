class Flight {
  final int? id;
  final String airline;
  final String flightNumber;
  final String departureDateTime;
  final String arrivalDateTime;
  final String departureAirport;
  final String arrivalAirport;
  final String classType;
  final String seatNumber;

  Flight({
    this.id,
    required this.airline,
    required this.flightNumber,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.classType,
    required this.seatNumber,
  });

  // Convert a Flight object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'],
      airline: map['airline'],
      flightNumber: map['flightNumber'],
      departureDateTime: map['departureDateTime'],
      arrivalDateTime: map['arrivalDateTime'],
      departureAirport: map['departureAirport'],
      arrivalAirport: map['arrivalAirport'],
      classType: map['classType'],
      seatNumber: map['seatNumber'],
    );
  }
}
