import 'package:flutter/material.dart';

Future<bool> confirmDeleteDialog(BuildContext context, String itemType) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete $itemType'),
          content: Text('Are you sure you want to delete this $itemType?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false;
}
