import 'package:flutter/material.dart';

/// Shows a confirmation dialog before deleting an item.
///
/// [context] – the build context to display the dialog in.
/// [itemType] – a label for what type of item is being deleted (e.g., 'trip', 'activity').
///
/// Returns `true` if the user confirms deletion, or `false` if they cancel or dismiss the dialog.
Future<bool> confirmDeleteDialog(BuildContext context, String itemType) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          // Dynamic title based on the item type
          title: Text('Delete $itemType'),
          content: Text('Are you sure you want to delete this $itemType?'),
          actions: [
            // Cancel button closes the dialog and returns false
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            // Delete button closes the dialog and returns true
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      )
      // If the dialog is dismissed without a selection, default to false
      ??
      false;
}
