class ViewOption {
  final int? id;
  final String viewType;
  final String selectedItineraryItem;

  ViewOption({
    this.id,
    required this.viewType,
    required this.selectedItineraryItem,
  });

  // Convert a View Option object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'viewType': viewType,
      'selectedItineraryItem': selectedItineraryItem,
    };
  }

  // Convert a Map into a View Option object
  factory ViewOption.fromMap(Map<String, dynamic> map) {
    return ViewOption(
      id: map['id'],
      viewType: map['viewType'],
      selectedItineraryItem: map['selectedItineraryItem'],
    );
  }
}
