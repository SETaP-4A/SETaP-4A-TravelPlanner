import 'package:flutter/material.dart';
import 'package:setap4a/models/user.dart';
import 'package:setap4a/services/user_profile_service.dart';

class LocalUserTestScreen extends StatefulWidget {
  @override
  _LocalUserTestScreenState createState() => _LocalUserTestScreenState();
}

class _LocalUserTestScreenState extends State<LocalUserTestScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  List<User> _localUsers = [];

  Future<void> _loadLocalUsers() async {
    final users = await _userProfileService.getAllLocalUsers();
    setState(() {
      _localUsers = users;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLocalUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Users Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLocalUsers,
          )
        ],
      ),
      body: _localUsers.isEmpty
          ? Center(child: Text('No local users found.'))
          : ListView.builder(
              itemCount: _localUsers.length,
              itemBuilder: (context, index) {
                final user = _localUsers[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Text(user.uid),
                );
              },
            ),
    );
  }
}
