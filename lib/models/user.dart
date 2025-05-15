class User {
  final int? id; // Local DB ID (SQLite only)
  final String
      uid; // Firebase UID — this uniquely identifies the user across platforms
  final String name;
  final String email; // User's email, required for login/account management

  User({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
  });

  // Converts the User object into a Map for storing in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid, // Include Firebase UID for syncing or lookup
      'name': name,
      'email': email,
    };
  }

  // Reconstructs a User from a Map (e.g., when loading from SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
    );
  }
}
