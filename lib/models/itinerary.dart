class Itinerary {
  final int? id;
  final String title;
  final int userId;

  Itinerary({
    this.id,
    required this.title,
    required this.userId,
  });

  // Converts a Itinerary object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
    };
  }

  // Converts a Map into an Itinerary object
  factory Itinerary.fromMap(Map<String, dynamic> map) {
    return Itinerary(
      id: map['id'],
      title: map['title'],
      userId: map['userId'],
    );
  }
}
