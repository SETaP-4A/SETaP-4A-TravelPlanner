import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:setap4a/db/database_helper.dart';
import 'package:setap4a/models/user.dart' as AppUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock classes for Firebase services
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late DatabaseHelper databaseHelper;

  setUpAll(() async {
    // Test initialization
    TestWidgetsFlutterBinding.ensureInitialized();
    // No need to initialize Firebase since we're mocking FirebaseAuth and Firestore
  });

  setUp(() {
    // Initialize mocked FirebaseAuth and Firestore instances
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();

    // Initialize AuthService with mocked Firebase instances
    authService =
        AuthService(firebaseAuth: mockFirebaseAuth, firestore: mockFirestore);
    databaseHelper = DatabaseHelper.instance;
  });

  test('Sign Up and sync user to SQLite', () async {
    final testUser = AppUser.User(
        uid: 'test-uid', name: 'John Doe', email: 'john@example.com');

    final mockUserCredential = MockUserCredential();
    final mockUser = MockUser();

    // When creating a user with Firebase, return the mock user credential
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: 'test@example.com', password: 'TestPassword123'))
        .thenAnswer((_) async => mockUserCredential);

    // Simulate the Firebase user being created successfully
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('john@example.com');

    // Insert user into SQLite
    final id = await databaseHelper.insertUser(testUser);
    expect(id, isNotNull);

    // Fetch from SQLite and verify the user is stored correctly
    final users = await databaseHelper.loadUsers();
    expect(users, isNotEmpty);
    expect(users.first['uid'], 'test-uid');
  });

  test('Sign In with valid credentials', () async {
    final email = 'testuser@example.com';
    final password = 'TestPassword123';

    final mockUserCredential = MockUserCredential();
    final mockUser = MockUser();

    // Simulate a successful sign-in with Firebase
    when(mockFirebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .thenAnswer((_) async => mockUserCredential);

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.email).thenReturn(email);

    final user = await authService.signInWithEmailPassword(email, password);

    expect(user, isNotNull);
    expect(user?.email, email);
  });

  test('Sign Out (Mock Firebase)', () async {
    // Simulate Firebase sign-out
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());

    await authService.signOut();
    expect(authService.getCurrentUser(), isNull);
  });
}
