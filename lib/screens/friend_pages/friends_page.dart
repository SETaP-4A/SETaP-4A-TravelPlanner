import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:setap4a/services/firebase_service.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? currentUserData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load the current user's info from Firestore (e.g., for future expansion)
    FirebaseService().getCurrentUserInfo().then((data) {
      setState(() {
        currentUserData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: "Search"),
            Tab(icon: Icon(Icons.person_add), text: "Requests"),
            Tab(icon: Icon(Icons.people), text: "Friends"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SearchUserTab(),
                FriendRequestsTab(),
                FriendsListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchUserTab extends StatefulWidget {
  @override
  _SearchUserTabState createState() => _SearchUserTabState();
}

class _SearchUserTabState extends State<SearchUserTab> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Start searching as soon as the user types 3+ characters
    _controller.addListener(() {
      final query = _controller.text.trim();
      if (query.length >= 3) {
        _search(query);
      } else {
        setState(() => searchResults = []);
      }
    });
  }

  // Basic user search using a FirebaseService helper
  void _search(String query) async {
    setState(() => loading = true);
    try {
      final results = await FirebaseService().searchUsersStartingWith(query);
      setState(() {
        searchResults = results;
        loading = false;
      });
    } catch (e) {
      print("❌ Search error: $e");
      setState(() {
        searchResults = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Search by username",
              suffixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          loading
              ? const CircularProgressIndicator()
              : searchResults.isEmpty
                  ? const Text("No users found")
                  : Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchResults[index];
                          return ListTile(
                            title: Text(user['username'] ?? 'Unknown'),
                            subtitle: Text(user['email'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () async {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser == null) return;

                                // Prevent sending duplicate friend requests
                                final currentUserDoc = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .get();

                                final outgoing = List<String>.from(
                                    currentUserDoc
                                            .data()?['outgoingRequests'] ??
                                        []);
                                final friends = List<String>.from(
                                    currentUserDoc.data()?['friends'] ?? []);

                                if (friends.contains(user['uid'])) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'You are already friends with ${user['username']}')),
                                  );
                                } else if (outgoing.contains(user['uid'])) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Friend request already sent to ${user['username']}')),
                                  );
                                } else {
                                  await FirebaseService()
                                      .sendFriendRequest(user['uid']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Friend request sent to ${user['username']}')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FriendRequestsTab extends StatefulWidget {
  @override
  _FriendRequestsTabState createState() => _FriendRequestsTabState();
}

class _FriendRequestsTabState extends State<FriendRequestsTab> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _loadRequests(); // Load on init
  }

  // Loads incoming & outgoing friend requests
  Future<List<Map<String, dynamic>>> _loadRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final data = doc.data();
    final incoming = List<String>.from(data?['incomingRequests'] ?? []);
    final outgoing = List<String>.from(data?['outgoingRequests'] ?? []);

    final requests = <Map<String, dynamic>>[];

    for (final uid in incoming) {
      final user = await FirebaseService().getUserByUid(uid);
      if (user != null) {
        user['requestType'] = 'incoming';
        requests.add(user);
      }
    }

    for (final uid in outgoing) {
      final user = await FirebaseService().getUserByUid(uid);
      if (user != null) {
        user['requestType'] = 'outgoing';
        requests.add(user);
      }
    }

    return requests;
  }

  void _handleAccept(String uid) async {
    await FirebaseService().acceptFriendRequest(uid);
    setState(() => _requestsFuture = _loadRequests());
  }

  void _handleReject(String uid) async {
    await FirebaseService().rejectFriendRequest(uid);
    setState(() => _requestsFuture = _loadRequests());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No friend requests"));
        }

        final requests = snapshot.data!;
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final user = requests[index];
            return ListTile(
              title: Text(user['username'] ?? 'Unknown'),
              subtitle: Text(user['requestType'] == 'incoming'
                  ? "Wants to be your friend"
                  : "Friend request sent (pending)"),
              trailing: user['requestType'] == 'incoming'
                  ? Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _handleAccept(user['uid']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () => _handleReject(user['uid']),
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

class FriendsListTab extends StatefulWidget {
  @override
  _FriendsListTabState createState() => _FriendsListTabState();
}

class _FriendsListTabState extends State<FriendsListTab> {
  late Future<List<Map<String, dynamic>>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = FirebaseService().getFriends(); // Load friends list
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _friendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No friends yet"));
        }

        final friends = snapshot.data!;
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(friend['username'] ?? 'Unnamed'),
              subtitle: Text(friend['email'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Remove Friend"),
                      content: Text(
                          "Are you sure you want to remove ${friend['username']}?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Remove"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseService().removeFriend(friend['uid']);
                    setState(() {
                      _friendsFuture = FirebaseService().getFriends();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${friend['username']} removed')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
