class Itinerary {
  int? id;
  String? firestoreId;
  String? title;
  String? startDate;
  String? endDate;
  String? location;
  String? description;
  String? comments;
  int? userId;

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
    );
  }

  Itinerary copyWith({String? firestoreId}) {
    return Itinerary(
      id: id,
      firestoreId: firestoreId ?? this.firestoreId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      location: location,
      description: description,
      comments: comments,
      userId: userId,
    );
  }
}
