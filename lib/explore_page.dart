import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Explore Destinations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Top Destination: Bali, Indonesia'),
          Text('Trending: Tokyo, Japan'),
          Text('Hidden Gem: Cape Town, South Africa'),
        ],
      ),
    );
  }
}
