// When getting data for this page, make it refresh each time it is opened because of how the edit page works
//
//

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:setap4a/screens/trip_pages/edit_trip_page.dart';

class TripDetailsPage extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip["name"] ?? "Trip Details"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditTripPage(trip: trip)));
              },
              icon: Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Image (Handles both asset and file images)
            _buildTripImage(),

            const SizedBox(height: 20),

            // Trip Name
            Text(
              trip["name"] ?? "Unnamed Trip",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Trip Details Section
            _buildDetail("DestiNation", trip["destination"]),
            _buildDetail("Start Date", trip["start_date"]),
            _buildDetail("End Date", trip["end_date"]),
            _buildDetail("Duration", trip["duration"]),
            _buildDetail("Vibe", trip["vibe"]),
            _buildDetail("Location", trip["location"]),
            _buildDetail("Description", trip["description"]),
            _buildDetail("Comments", trip["comments"]),

            const SizedBox(height: 10),

            // Friends Section
            _buildListSection("Friends", trip["friends"]),

            const SizedBox(height: 10),

            // Activities Section
            _buildListSection("Activities", trip["activities"]),
          ],
        ),
      ),
    );
  }

  // Function to build the trip image (handles asset & file paths)
  Widget _buildTripImage() {
    if (trip["image"] != null && trip["image"].isNotEmpty) {
      if (trip["image"].startsWith("assets/")) {
        return Image.asset(
          trip["image"],
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (File(trip["image"]).existsSync()) {
        return Image.file(
          File(trip["image"]),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    // Default placeholder image
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.camera_alt, size: 50, color: Colors.black54),
    );
  }

  // Function to build a trip detail row
  Widget _buildDetail(String label, String? value) {
    return value != null && value.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("$label: $value", style: const TextStyle(fontSize: 16)),
          )
        : const SizedBox();
  }

  // Function to build a section for lists (Friends, Activities)
  Widget _buildListSection(String title, List<dynamic>? items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _headerStyle),
        const SizedBox(height: 5),
        if (items != null && items.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text("• $item", style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
          )
        else
          const Text("No data available.",
              style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  static const TextStyle _headerStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
