import 'dart:convert';
class Trip {
  final int? id;
  final String destination;
  final String date;
  final String duration;
  final String name;
  final String? image;
  final List<String> friends;
  final String start_date;
  final String end_date;
  final String vibe;
  final String location;
  final String description;
  final String comments;
  final List<String> activities;

  Trip({
    this.id,
    required this.destination,
    required this.date,
    required this.duration,
    required this.name,
    this.image,
    required this.friends,
    required this.start_date,
    required this.end_date,
    required this.vibe,
    required this.location,
    required this.description,
    required this.comments,
    required this.activities,
  });

  // Convert a Trip object into a Map
  Map<String, dynamic> toMap() {
    return {
      'destination': destination,
      'date': date,
      'duration': duration,
      'name': name,
      'image': image,
      'friends': json.encode(friends),
      'start_date': start_date,
      'end_date': end_date,
      'vibe': vibe,
      'location': location,
      'description': description,
      'comments': comments,
      'activities': json.encode(activities)
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      destination: map['destination'],
      date: map['date'],
      duration: map['duration'],
      name: map['name'],
      image: map['image'],
      friends: List<String>.from(json.decode(map['friends'])),
      start_date: map['start_date'],
      end_date: map['end_date'],
      vibe: map['vibe'],
      location: map['location'],
      description: map['description'],
      comments: map['comments'],
      activities: List<String>.from(json.decode(map['activities']))
    );
  }
}