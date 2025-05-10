import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:math';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Sync itineraries to Firebase
  Future<void> syncItineraries(
      String userId, List<Map<String, dynamic>> itineraries) async {
    for (var itinerary in itineraries) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('itineraries')
            .add(itinerary);
        print("✅ Itinerary synced to Firebase.");
      } catch (e) {
        print("❌ Error syncing itinerary: $e");
      }
    }
  }

  // Sync accommodations to Firebase under a specific itinerary
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
        print("✅ Accommodation synced to Firebase.");
      } catch (e) {
        print("❌ Error syncing accommodation: $e");
      }
    }
  }

  // Sync flights to Firebase under a specific itinerary
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
        print("✅ Flight synced to Firebase.");
      } catch (e) {
        print("❌ Error syncing flight: $e");
      }
    }
  }

  // Sync activities to Firebase under a specific itinerary
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
        print("✅ Activity synced to Firebase.");
      } catch (e) {
        print("❌ Error syncing activity: $e");
      }
    }
  }

  // Packing list is not itinerary-specific (assuming)
  Future<void> syncPackingList(
      String userId, List<Map<String, dynamic>> packingList) async {
    for (var item in packingList) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('packingList')
            .add(item);
        print("✅ Packing list item synced to Firebase.");
      } catch (e) {
        print("❌ Error syncing packing list: $e");
      }
    }
  }

  // Generate a new DEK
  String _generateDataEncryptionKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Get or generate the DEK
  Future<String> _getDataEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'data_encryption_key');
    if (key == null) {
      key = _generateDataEncryptionKey();
      await _secureStorage.write(key: 'data_encryption_key', value: key);
    }
    return key;
  }

  // Encrypt data before sending to Firebase
  Future<Map<String, String>> encryptData(Map<String, dynamic> data) async {
    final keyString = await _getDataEncryptionKey();
    final key = encrypt.Key.fromBase64(keyString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    Map<String, String> encryptedData = {};

    data.forEach((k, v) {
      if (v is String) {
        final iv = encrypt.IV.fromSecureRandom(16); // Generate IV per field
        final encrypted = encrypter.encrypt(v, iv: iv);
        encryptedData[k] = encrypted.base64;
        encryptedData['${k}_iv'] = iv.base64; // Store IV per field
      } else {
        encryptedData[k] = v.toString();
      }
    });

    return encryptedData;
  }

  // Decrypt data retrieved from Firebase
  Future<Map<String, dynamic>> decryptData(
      Map<String, dynamic> encryptedData) async {
    try {
      final keyString = await _getDataEncryptionKey();
      final key = encrypt.Key.fromBase64(keyString);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      Map<String, dynamic> decryptedData = {};

      encryptedData.forEach((k, v) {
        if (k.endsWith('_iv')) return; // Skip IV keys
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

  // Send encrypted data to Firebase
  Future<void> sendEncryptedData(
      String collectionName, Map<String, dynamic> data) async {
    final encryptedData = await encryptData(data);
    await _firestore.collection(collectionName).add(encryptedData);
  }

  // Retrieve and decrypt data from Firebase
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
