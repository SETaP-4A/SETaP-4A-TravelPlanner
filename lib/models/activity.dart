class Activity {
  final int? id;
  final String name;
  final String type;
  final String location;
  final String dateTime;
  final String duration;
  final String notes;

  Activity({
    this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.dateTime,
    required this.duration,
    required this.notes,
  });

  // Convert an Activity object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'dateTime': dateTime,
      'duration': duration,
      'notes': notes,
    };
  }

  // Convert a Map into an Activity object
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      location: map['location'],
      dateTime: map['dateTime'],
      duration: map['duration'],
      notes: map['notes'],
    );
  }
}
