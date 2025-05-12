import 'package:flutter/material.dart';

class SectionedItemList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) formatter;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;
  final bool isViewer;

  const SectionedItemList({
    super.key,
    required this.title,
    required this.items,
    required this.formatter,
    this.onEdit,
    this.onDelete,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(formatter(item),
                      style: const TextStyle(fontSize: 16)),
                  trailing: isViewer || onEdit == null || onDelete == null
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 20, color: Colors.blueAccent),
                              tooltip: "Edit",
                              onPressed: () => onEdit!(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: Colors.redAccent),
                              tooltip: "Delete",
                              onPressed: () => onDelete!(item),
                            ),
                          ],
                        ),
                ),
              ))
        ],
      ),
    );
  }
}
