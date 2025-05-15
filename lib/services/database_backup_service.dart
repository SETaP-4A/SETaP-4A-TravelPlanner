import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

class DatabaseBackupService {
  // Get the current database file path from the DatabaseHelper
  Future<String> _getDatabasePath() async {
    final path = await getDatabasesPath();
    return join(path, 'secure_database.db');
  }

  // Backup the database to a local file and upload it to Firebase Storage
  Future<void> backupDatabaseToFirebase() async {
    try {
      final dbPath = await _getDatabasePath();
      final backupFile = await _createBackupFile(dbPath);

      // Upload the backup file to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('backups/secure_database_backup.db');
      await storageRef.putFile(backupFile);
      print("Backup uploaded to Firebase Storage successfully");
    } catch (e) {
      print("Error during database backup: $e");
    }
  }

  // Create a backup of the database by copying it to a new file
  Future<File> _createBackupFile(String dbPath) async {
    final backupDir = await getApplicationDocumentsDirectory();
    final backupPath = join(backupDir.path, 'secure_database_backup.db');
    final backupFile = File(backupPath);

    // Copy the current database to the backup file
    final originalFile = File(dbPath);
    if (await originalFile.exists()) {
      await originalFile.copy(backupPath);
    } else {
      throw Exception('Original database file not found');
    }

    return backupFile;
  }

  // Restore the database from a backup file stored locally
  Future<void> restoreDatabaseFromBackup() async {
    try {
      final dbPath = await _getDatabasePath();
      final backupFile = await _getBackupFileFromFirebase();

      if (backupFile != null) {
        // Copy the backup file to the database path
        await backupFile.copy(dbPath);
        print("Database restored successfully");
      } else {
        print("No backup found in Firebase Storage.");
      }
    } catch (e) {
      print("Error during database restore: $e");
    }
  }

  // Retrieve the backup file from Firebase Storage
  Future<File?> _getBackupFileFromFirebase() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('backups/secure_database_backup.db');
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = join(tempDir.path, 'secure_database_backup.db');
      final tempFile = File(tempFilePath);

      // Download the backup file from Firebase Storage
      await storageRef.writeToFile(tempFile);
      print("Backup file downloaded from Firebase Storage");

      return tempFile;
    } catch (e) {
      print("Error downloading backup file from Firebase Storage: $e");
      return null;
    }
  }
}
