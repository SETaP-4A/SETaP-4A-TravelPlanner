class PackingList {
  final int? id;
  final String itemName;
  final String quantity;
  final String category;
  final String priority;
  final String checked;

  PackingList({
    this.id,
    required this.itemName,
    required this.quantity,
    required this.category,
    required this.priority,
    required this.checked,
  });

  // Convert a Packing List item into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'category': category,
      'priority': priority,
      'checked': checked,
    };
  }

  // Convert a Map into a Packing List item
  factory PackingList.fromMap(Map<String, dynamic> map) {
    return PackingList(
      id: map['id'],
      itemName: map['itemName'],
      quantity: map['quantity'],
      category: map['category'],
      priority: map['priority'],
      checked: map['checked'],
    );
  }
}
