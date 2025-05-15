import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:setap4a/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:setap4a/services/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  UserProfileService,
])
import 'auth_service_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockUserCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockUserProfileService mockUserProfileService;
  late AuthService authService;

  setUp(() async {
    // Mock SharedPreferences globally
    SharedPreferences.setMockInitialValues({});

    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUserCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockUserProfileService = MockUserProfileService();

    // Firestore chain
    when(mockFirestore.collection(any)).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(any)).thenReturn(mockUserDoc);
    when(mockUserDoc.set(any, any)).thenAnswer((_) async => null);

    // Avoid actual SQLite access in tests
    when(mockUserProfileService.syncUserProfileToSQLite(any))
        .thenAnswer((_) async => {});

    authService = AuthService(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
      userProfileService: mockUserProfileService,
    );
  });

  test('Sign Up with email and sync user', () async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'TestPassword123',
    )).thenAnswer((_) async => mockUserCredential);

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.email).thenReturn('test@example.com');

    final user = await authService.signUpWithEmailPassword(
      'test@example.com',
      'TestPassword123',
      'John Doe',
    );

    expect(user, isNotNull);
    expect(user?.uid, 'test-uid');
  });

  test('Sign In with valid credentials', () async {
    const email = 'testuser@example.com';
    const password = 'TestPassword123';

    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    )).thenAnswer((_) async => mockUserCredential);

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUser.displayName).thenReturn('John Doe');
    when(mockUser.email).thenReturn(email);

    final user = await authService.signInWithEmailPassword(email, password);
    expect(user, isNotNull);
    expect(user?.email, email);
  });

  test('Sign Out (Mock Firebase)', () async {
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
    await authService.signOut();
    // Can't assert much because getCurrentUser is just a passthrough
  });
}
