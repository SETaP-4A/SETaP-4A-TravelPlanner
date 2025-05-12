import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:setap4a/models/itinerary.dart';

class TripCard extends StatelessWidget {
  final Itinerary trip;
  final bool isFeatured;
  final VoidCallback? onDelete;
  final List<String>? collaboratorNames;

  const TripCard({
    super.key,
    required this.trip,
    this.isFeatured = false,
    this.onDelete,
    this.collaboratorNames,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = trip.ownerUid == FirebaseAuth.instance.currentUser?.uid;
    final isEditor = trip.permission == 'editor';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: isFeatured ? 20.0 : 12.0,
        ),
        leading: Icon(
          Icons.flight_takeoff,
          color: Colors.blueAccent,
          size: isFeatured ? 32 : 24,
        ),
        title: Text(
          trip.title ?? 'Unnamed Trip',
          style: TextStyle(
            fontSize: isFeatured ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.startDate ?? '',
              style: TextStyle(
                color: isOwner ? Colors.black : Colors.blueGrey,
              ),
            ),
            if (!isOwner)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isEditor ? Colors.blue.shade50 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEditor
                        ? "Collaborator (Editor)"
                        : "Collaborator (Viewer)",
                    style: TextStyle(
                      fontSize: 12,
                      color: isEditor ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            if (isOwner &&
                collaboratorNames != null &&
                collaboratorNames!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "👥 Shared with: ${collaboratorNames!.join(', ')}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        trailing: isOwner
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
