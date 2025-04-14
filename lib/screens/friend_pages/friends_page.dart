import 'package:flutter/material.dart';

class FriendProfilePage extends StatelessWidget {
  final String name;
  final String trip;

  const FriendProfilePage({super.key, required this.name, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              trip,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Share Travel Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

// Update FriendsPage to navigate to FriendProfilePage with Add Friend option
class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, String>> friends = [
    {'name': 'John Doe', 'trip': 'Traveling to Rome'},
    {'name': 'Jane Smith', 'trip': 'Exploring Thailand'},
    {'name': 'Alice Johnson', 'trip': 'Backpacking in Peru'},
  ];

  void _addFriend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String input = '';
        return AlertDialog(
          title: const Text('Add Friend'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Enter Profile Link or Details',
            ),
            onChanged: (value) => input = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _processFriendInput(input);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _processFriendInput(String input) {
    if (input.startsWith('travelapp://addfriend')) {
      Uri uri = Uri.parse(input);
      String? name = uri.queryParameters['name'];
      String? trip = uri.queryParameters['trip'];

      if (name != null && trip != null) {
        setState(() {
          friends.add({'name': name, 'trip': trip});
        });
      }
    } else {
      List<String> parts = input.split(' - ');
      if (parts.length == 2) {
        setState(() {
          friends.add({'name': parts[0], 'trip': parts[1]});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, title: const Text('Friends List')),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(friends[index]['name']!),
              subtitle: Text(friends[index]['trip']!),
              leading: const Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendProfilePage(
                      name: friends[index]['name']!,
                      trip: friends[index]['trip']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFriend,
        child: const Icon(Icons.add),
      ),
    );
  }
}
