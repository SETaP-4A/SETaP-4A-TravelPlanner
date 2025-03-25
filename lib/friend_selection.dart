import 'package:flutter/material.dart';

class SelectFriendsPage extends StatefulWidget {
  final List<String> selectedFriends;

  const SelectFriendsPage(this.selectedFriends, {super.key});

  @override
  _SelectFriendsPageState createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  final List<String> allFriends = ["Alice", "Bob", "Charlie", "David", "Emma"];
  late List<String> selectedFriends;

  @override
  void initState() {
    super.initState();
    selectedFriends = List.from(widget.selectedFriends);
  }

  void _toggleFriendSelection(String friend) {
    setState(() {
      if (selectedFriends.contains(friend)) {
        selectedFriends.remove(friend);
      } else {
        selectedFriends.add(friend);
      }
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, selectedFriends);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Friends")),
      body: ListView.builder(
        itemCount: allFriends.length,
        itemBuilder: (context, index) {
          final friend = allFriends[index];
          final isSelected = selectedFriends.contains(friend);

          return ListTile(
            title: Text(friend),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.circle_outlined),
            onTap: () => _toggleFriendSelection(friend),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmSelection,
        child: const Icon(Icons.check),
      ),
    );
  }
}
