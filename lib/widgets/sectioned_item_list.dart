import 'package:flutter/material.dart';

/// A reusable widget that displays a titled list section with optional icon.
/// Each item in the list is formatted via a provided formatter function,
/// and optionally can show edit and delete buttons if callbacks are provided
/// and the user is not a viewer (read-only).
class SectionedItemList extends StatelessWidget {
  final String title; // Section title (e.g., "Flights", "Accommodations")
  final IconData? icon; // Optional icon displayed next to the title
  final List<Map<String, dynamic>> items; // List of data items to display
  final String Function(Map<String, dynamic>) formatter;
  // Formatter to convert each item into a multi-line display string

  final void Function(Map<String, dynamic>)? onEdit; // Callback for edit button
  final void Function(Map<String, dynamic>)?
      onDelete; // Callback for delete button
  final bool isViewer; // If true, disables editing (read-only mode)

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
    // If no items, return an empty widget to avoid unnecessary UI
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24), // Spacing above section
          Row(
            children: [
              if (icon != null) Icon(icon, size: 22), // Optional section icon
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Spacing below title

          // Map each item to a Card widget with formatted content
          ...items.map((item) {
            final formatted = formatter(item);
            final lines = formatted.split('\n'); // Split into lines for layout

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
                    // First line in bold (usually the main title)
                    if (lines.isNotEmpty)
                      Text(
                        lines[0],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    // Second line in slightly muted color (usually subtitle)
                    if (lines.length > 1)
                      Text(
                        lines[1],
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha((0.75 * 255).round()),
                        ),
                      ),
                    // Third line in normal text style (additional details)
                    if (lines.length > 2)
                      Text(
                        lines[2],
                        style: const TextStyle(fontSize: 15),
                      ),
                  ],
                ),
                // Show edit/delete buttons only if user has permission and callbacks provided
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
