class Itinerary {
  int? id; // Local DB ID (used in SQLite)
  String? firestoreId; // Firestore document ID
  String? title;
  String? startDate; // Stored as a formatted string
  String? endDate;
  String? location;
  String? description; // Optional trip description
  String? comments; // Notes, group chat stuff, etc.
  int? userId; // Local DB link to user (SQLite user.id)
  String? ownerUid; // Firebase UID of the trip owner
  List<String>? collaborators; // List of user UIDs who are invited
  final String? permission; // 'viewer' or 'editor' (for current user context)

  Itinerary({
    this.id,
    this.firestoreId,
    this.title,
    this.startDate,
    this.endDate,
    this.location,
    this.description,
    this.comments,
    this.userId,
    this.ownerUid,
    this.collaborators,
    this.permission,
  });

  // Convert Itinerary to a map for saving to DB or Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'description': description,
      'comments': comments,
      'userId': userId,
      'ownerUid': ownerUid,
      'collaborators': collaborators,
      'permission': permission,
    };
  }

  // Construct Itinerary from map (e.g. after loading from DB or Firebase)
  factory Itinerary.fromMap(Map<String, dynamic> map, {String? firestoreId}) {
    return Itinerary(
      id: map['id'],
      firestoreId: firestoreId, // Firestore ID might be passed separately
      title: map['title'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      location: map['location'],
      description: map['description'],
      comments: map['comments'],
      userId: map['userId'],
      ownerUid: map['ownerUid'],
      collaborators: map['collaborators'] != null
          ? List<String>.from(map['collaborators']) // Defensive copy
          : [],
      permission: map['permission'],
    );
  }

  // Utility method to clone this object while changing some fields
  Itinerary copyWith({
    int? id,
    String? firestoreId,
    String? title,
    String? startDate,
    String? endDate,
    String? location,
    String? description,
    String? comments,
    int? userId,
    String? ownerUid,
    List<String>? collaborators,
    String? permission,
  }) {
    return Itinerary(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      description: description ?? this.description,
      comments: comments ?? this.comments,
      userId: userId ?? this.userId,
      ownerUid: ownerUid ?? this.ownerUid,
      collaborators: collaborators ?? this.collaborators,
      permission: permission ?? this.permission,
    );
  }
}
