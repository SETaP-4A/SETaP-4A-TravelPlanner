class Notification {
  final int? id;
  final String type;
  final String device;

  Notification({
    this.id,
    required this.type,
    required this.device,
  });

  // Convert a Notification object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'device': device,
    };
  }

  // Convert a Map into a Notification object
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      type: map['type'],
      device: map['device'],
    );
  }
}
