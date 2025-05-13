class Itinerary {
  int? id;
  String? firestoreId;
  String? title;
  String? startDate;
  String? endDate;
  String? location;
  String? description;
  String? comments;
  int? userId; // local DB id
  String? ownerUid; // Firebase UID
  List<String>? collaborators;
  final String? permission; // 'viewer' or 'editor'

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

  factory Itinerary.fromMap(Map<String, dynamic> map, {String? firestoreId}) {
    return Itinerary(
      id: map['id'],
      firestoreId: firestoreId,
      title: map['title'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      location: map['location'],
      description: map['description'],
      comments: map['comments'],
      userId: map['userId'],
      ownerUid: map['ownerUid'],
      collaborators: map['collaborators'] != null
          ? List<String>.from(map['collaborators'])
          : [],
      permission: map['permission'],
    );
  }

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
