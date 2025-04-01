class User {
  final int? id;
  final String uid; // Firebase UID
  final String name;
  final String email; // Email of the user

  User({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
  });

  // Convert a User object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid, // Add uid to the map
      'name': name,
      'email': email, // Add email to the map
    };
  }

  // Convert a Map into a User object from SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      uid: map['uid'], // Retrieve uid from the map
      name: map['name'],
      email: map['email'], // Retrieve email from the map
    );
  }
}
