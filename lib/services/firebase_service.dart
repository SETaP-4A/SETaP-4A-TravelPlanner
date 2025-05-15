import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:math';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> syncItineraries(
      String userId, List<Map<String, dynamic>> itineraries) async {
    for (var itinerary in itineraries) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('itineraries')
            .add(itinerary);
        print("Itinerary synced to Firebase.");
      } catch (e) {
        print("Error syncing itinerary: $e");
      }
    }
  }

  Future<void> syncAccommodations(String userId,
      List<Map<String, dynamic>> accommodations, String itineraryId) async {
    for (var accommodation in accommodations) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('itineraries')
            .doc(itineraryId)
            .collection('accommodations')
            .add(accommodation);
        print("Accommodation synced to Firebase.");
      } catch (e) {
        print("Error syncing accommodation: $e");
      }
    }
  }

  Future<void> syncFlights(String userId, List<Map<String, dynamic>> flights,
      String itineraryId) async {
    for (var flight in flights) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('itineraries')
            .doc(itineraryId)
            .collection('flights')
            .add(flight);
        print("Flight synced to Firebase.");
      } catch (e) {
        print("Error syncing flight: $e");
      }
    }
  }

  Future<void> syncActivities(String userId,
      List<Map<String, dynamic>> activities, String itineraryId) async {
    for (var activity in activities) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('itineraries')
            .doc(itineraryId)
            .collection('activities')
            .add(activity);
        print("Activity synced to Firebase.");
      } catch (e) {
        print("Error syncing activity: $e");
      }
    }
  }

  Future<void> syncPackingList(
      String userId, List<Map<String, dynamic>> packingList) async {
    for (var item in packingList) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('packingList')
            .add(item);
        print("Packing list item synced to Firebase.");
      } catch (e) {
        print("Error syncing packing list: $e");
      }
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> searchUsersByUsername(String query) async {
    print("Searching for username: $query");

    if (query.isEmpty) return [];

    final usernameDoc =
        await _firestore.collection('usernames').doc(query).get();

    if (!usernameDoc.exists) {
      print("Username not found in 'usernames' collection.");
      return [];
    }

    final uid = usernameDoc['uid'];
    print("Found UID: $uid for username: $query");

    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      print("UID $uid not found in 'users' collection.");
      return [];
    }

    final data = userDoc.data();
    print("Final user data: $data");

    return [data!..['uid'] = uid];
  }

  Future<List<String>> getIncomingRequests() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("Not logged in");

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    return List<String>.from(doc.data()?['incomingRequests'] ?? []);
  }

  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? {'uid': doc.id, ...doc.data()!} : null;
  }

  Future<List<Map<String, dynamic>>> searchUsersStartingWith(
      String prefix) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final lowerPrefix = prefix.toLowerCase();

    final querySnapshot = await _firestore
        .collection('users')
        .where('username_lowercase', isGreaterThanOrEqualTo: lowerPrefix)
        .where('username_lowercase', isLessThan: lowerPrefix + 'z')
        .get();

    return querySnapshot.docs
        .where((doc) => doc.id != currentUser.uid)
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final currentUserDoc = _firestore.collection('users').doc(currentUser.uid);
    final targetUserDoc = _firestore.collection('users').doc(targetUid);

    await _firestore.runTransaction((txn) async {
      final senderSnap = await txn.get(currentUserDoc);
      final targetSnap = await txn.get(targetUserDoc);

      final senderData = senderSnap.data() ?? {};
      final targetData = targetSnap.data() ?? {};

      final senderOutgoing =
          List<String>.from(senderData['outgoingRequests'] ?? []);
      final targetIncoming =
          List<String>.from(targetData['incomingRequests'] ?? []);
      final senderFriends = List<String>.from(senderData['friends'] ?? []);

      if (senderOutgoing.contains(targetUid) ||
          senderFriends.contains(targetUid)) {
        throw Exception(
            "Friend request already sent or you're already friends.");
      }

      senderOutgoing.add(targetUid);
      targetIncoming.add(currentUser.uid);

      txn.update(currentUserDoc, {'outgoingRequests': senderOutgoing});
      txn.update(targetUserDoc, {'incomingRequests': targetIncoming});
    });
  }

  Future<void> acceptFriendRequest(String fromUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final currentUserDoc = _firestore.collection('users').doc(currentUser.uid);
    final fromUserDoc = _firestore.collection('users').doc(fromUid);

    await _firestore.runTransaction((txn) async {
      final currentSnap = await txn.get(currentUserDoc);
      final fromSnap = await txn.get(fromUserDoc);

      final currentFriends =
          List<String>.from(currentSnap.data()?['friends'] ?? []);
      final fromFriends = List<String>.from(fromSnap.data()?['friends'] ?? []);

      final incoming =
          List<String>.from(currentSnap.data()?['incomingRequests'] ?? []);
      final outgoing =
          List<String>.from(fromSnap.data()?['outgoingRequests'] ?? []);

      if (!currentFriends.contains(fromUid)) currentFriends.add(fromUid);
      if (!fromFriends.contains(currentUser.uid))
        fromFriends.add(currentUser.uid);

      incoming.remove(fromUid);
      outgoing.remove(currentUser.uid);

      txn.update(currentUserDoc,
          {'friends': currentFriends, 'incomingRequests': incoming});

      txn.update(
          fromUserDoc, {'friends': fromFriends, 'outgoingRequests': outgoing});
    });
  }

  Future<void> rejectFriendRequest(String fromUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final currentUserDoc = _firestore.collection('users').doc(currentUser.uid);
    final fromUserDoc = _firestore.collection('users').doc(fromUid);

    await _firestore.runTransaction((txn) async {
      final currentSnap = await txn.get(currentUserDoc);
      final fromSnap = await txn.get(fromUserDoc);

      final incoming =
          List<String>.from(currentSnap.data()?['incomingRequests'] ?? []);
      final outgoing =
          List<String>.from(fromSnap.data()?['outgoingRequests'] ?? []);

      incoming.remove(fromUid);
      outgoing.remove(currentUser.uid);

      txn.update(currentUserDoc, {'incomingRequests': incoming});
      txn.update(fromUserDoc, {'outgoingRequests': outgoing});
    });
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final friendUids = List<String>.from(userDoc.data()?['friends'] ?? []);

    final friends = <Map<String, dynamic>>[];
    for (String uid in friendUids) {
      final friendDoc = await _firestore.collection('users').doc(uid).get();
      if (friendDoc.exists) friends.add(friendDoc.data()!);
    }

    return friends;
  }

  Future<void> removeFriend(String friendUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final currentUserDoc = _firestore.collection('users').doc(currentUser.uid);
    final friendUserDoc = _firestore.collection('users').doc(friendUid);

    await _firestore.runTransaction((txn) async {
      final currentSnap = await txn.get(currentUserDoc);
      final friendSnap = await txn.get(friendUserDoc);

      final currentFriends =
          List<String>.from(currentSnap.data()?['friends'] ?? []);
      final friendFriends =
          List<String>.from(friendSnap.data()?['friends'] ?? []);

      currentFriends.remove(friendUid);
      friendFriends.remove(currentUser.uid);

      txn.update(currentUserDoc, {'friends': currentFriends});
      txn.update(friendUserDoc, {'friends': friendFriends});
    });
  }

  String _generateDataEncryptionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  Future<String> _getDataEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'data_encryption_key');
    if (key == null) {
      key = _generateDataEncryptionKey();
      await _secureStorage.write(key: 'data_encryption_key', value: key);
    }
    return key;
  }

  Future<Map<String, String>> encryptData(Map<String, dynamic> data) async {
    final keyString = await _getDataEncryptionKey();
    final key = encrypt.Key.fromBase64(keyString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    Map<String, String> encryptedData = {};

    data.forEach((k, v) {
      if (v is String) {
        final iv = encrypt.IV.fromSecureRandom(16);
        final encrypted = encrypter.encrypt(v, iv: iv);
        encryptedData[k] = encrypted.base64;
        encryptedData['${k}_iv'] = iv.base64;
      } else {
        encryptedData[k] = v.toString();
      }
    });

    return encryptedData;
  }

  Future<Map<String, dynamic>> decryptData(
      Map<String, dynamic> encryptedData) async {
    try {
      final keyString = await _getDataEncryptionKey();
      final key = encrypt.Key.fromBase64(keyString);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      Map<String, dynamic> decryptedData = {};

      encryptedData.forEach((k, v) {
        if (k.endsWith('_iv')) return;
        if (v is String && encryptedData.containsKey('${k}_iv')) {
          try {
            final iv =
                encrypt.IV.fromBase64(encryptedData['${k}_iv'] as String);
            final decrypted = encrypter.decrypt64(v, iv: iv);
            decryptedData[k] = decrypted;
          } catch (e) {
            print("Decryption error for field '$k': $e");
            decryptedData[k] = "Error decrypting data";
          }
        } else {
          decryptedData[k] = v;
        }
      });

      return decryptedData;
    } catch (e) {
      print("Decryption failed: $e");
      return {};
    }
  }

  Future<void> sendEncryptedData(
      String collectionName, Map<String, dynamic> data) async {
    final encryptedData = await encryptData(data);
    await _firestore.collection(collectionName).add(encryptedData);
  }

  Future<List<Map<String, dynamic>>> getDecryptedData(
      String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();
    List<Map<String, dynamic>> decryptedDataList = [];

    for (var doc in snapshot.docs) {
      final decryptedData = await decryptData(doc.data());
      decryptedDataList.add(decryptedData);
    }

    return decryptedDataList;
  }
}
