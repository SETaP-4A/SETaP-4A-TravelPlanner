import 'package:flutter/material.dart';
import 'dart:io';

class TripDetailsPage extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trip["name"] ?? "Trip Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Image
            trip["image"] != null && File(trip["image"]).existsSync()
                ? Image.file(File(trip["image"]),
                    height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 50, color: Colors.black54),
                  ),

            const SizedBox(height: 20),

            // Trip Name
            Text(
              trip["name"] ?? "Unnamed Trip",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Trip Details
            _buildDetail("Destination", trip["destination"]),
            _buildDetail("Start Date", trip["start_date"]),
            _buildDetail("End Date", trip["end_date"]),
            _buildDetail("Duration", trip["duration"]),
            _buildDetail("Vibe", trip["vibe"]),
            _buildDetail("Location", trip["location"]),
            _buildDetail("Description", trip["description"]),
            _buildDetail("Comments", trip["comments"]),

            // Friends
            const SizedBox(height: 10),
            Text("Friends", style: _headerStyle),
            const SizedBox(height: 5),
            trip["friends"] != null && trip["friends"].isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: trip["friends"].map<Widget>((friend) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 5),
                        child: Text("• $friend",
                            style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                  )
                : const Text("No friends added yet.",
                    style: TextStyle(color: Colors.grey)),

            // Activities
            const SizedBox(height: 10),
            Text("Activities", style: _headerStyle),
            const SizedBox(height: 5),
            trip["activities"] != null && trip["activities"].isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: trip["activities"].map<Widget>((activity) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 5),
                        child: Text("• $activity",
                            style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                  )
                : const Text("No activities planned yet.",
                    style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String? value) {
    return value != null && value.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("$label: $value", style: const TextStyle(fontSize: 16)),
          )
        : const SizedBox();
  }

  static const TextStyle _headerStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
