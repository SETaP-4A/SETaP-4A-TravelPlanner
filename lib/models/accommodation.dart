class Accommodation {
  final String? id;
  final String itineraryFirestoreId;
  final String name;
  final String location;
  final String checkInDate;
  final String checkOutDate;
  final String bookingConfirmation;
  final String roomType;
  final double pricePerNight;
  final String facilities;

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

  // Convert an Accommodation object into a Map
  Map<String, dynamic> toMap() {
    return {
      'itineraryFirestoreId': itineraryFirestoreId,
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
  factory Accommodation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Accommodation(
      id: id,
      itineraryFirestoreId: map['itineraryFirestoreId'],
      name: map['name'],
      location: map['location'],
      checkInDate: map['checkInDate'],
      checkOutDate: map['checkOutDate'],
      bookingConfirmation: map['bookingConfirmation'],
      roomType: map['roomType'],
      pricePerNight: () {
        final raw = map['pricePerNight'];
        if (raw is num) return raw.toDouble();
        if (raw is String) {
          final parsed = double.tryParse(raw);
          if (parsed != null) return parsed;
          print("❌ Invalid pricePerNight: $raw");
        }
        return 0.0;
      }(),
      facilities: map['facilities'],
    );
  }
}
