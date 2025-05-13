import 'package:flutter/material.dart';

class SectionedItemList extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) formatter;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;
  final bool isViewer;

  const SectionedItemList({
    super.key,
    required this.title,
    this.icon,
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
          const SizedBox(height: 24),
          Row(
            children: [
              if (icon != null) Icon(icon, size: 22),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final formatted = formatter(item);

            final lines = formatted.split('\n');

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lines.isNotEmpty)
                      Text(
                        lines[0],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    if (lines.length > 1)
                      Text(
                        lines[1],
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.75),
                        ),
                      ),
                    if (lines.length > 2)
                      Text(
                        lines[2],
                        style: const TextStyle(fontSize: 15),
                      ),
                  ],
                ),
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
            );
          }),
        ],
      ),
    );
  }
}
