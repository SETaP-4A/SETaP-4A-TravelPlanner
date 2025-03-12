class Accommodation {
  final int? id;
  final String name;
  final String location;
  final String checkInDate;
  final String checkOutDate;
  final String bookingConfirmation;
  final String roomType;
  final String pricePerNight;
  final String facilities;

  Accommodation({
    this.id,
    required this.name,
    required this.location,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingConfirmation,
    required this.roomType,
    required this.pricePerNight,
    required this.facilities,
  });

  // Convert an Accommodation object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'bookingConfirmation': bookingConfirmation,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'facilities': facilities,
    };
  }

  // Convert a Map into an Accommodation object
  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      checkInDate: map['checkInDate'],
      checkOutDate: map['checkOutDate'],
      bookingConfirmation: map['bookingConfirmation'],
      roomType: map['roomType'],
      pricePerNight: map['pricePerNight'],
      facilities: map['facilities'],
    );
  }
}
