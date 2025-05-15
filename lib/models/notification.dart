class Notification {
  final int? id; // Local database ID (optional)
  final String type; // e.g. "tripReminder", "friendRequest"
  final String device; // Device type or ID this notification is for

  Notification({
    this.id,
    required this.type,
    required this.device,
  });

  // Converts the Notification object into a Map (for SQLite or syncing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'device': device,
    };
  }

  // Creates a Notification from a map (from database or JSON)
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      type: map['type'],
      device: map['device'],
    );
  }
}
