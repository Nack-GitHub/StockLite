import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/services/auth_service.dart';
import '../test_helpers.dart';

void main() {
  late AuthService authService;
  late auth_mocks.MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = auth_mocks.MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('AuthService - Advanced Testing', () {
    test('State Transition: Authentication status lifecycle', () async {
      // State: Logged Out
      expect(authService.currentUser, isNull);

      // Event: Sign Up (Transition to Logged In)
      await authService.signUp(
        email: 'transition@test.com',
        password: 'password123',
        name: 'Transition User',
        onCreateProfile: (uid, name, email) async {},
      );
      expect(authService.currentUser, isNotNull);

      // Event: Sign Out (Transition to Logged Out)
      await authService.signOut();
      expect(authService.currentUser, isNull);
    });

    test('Use Case: Complete User Auth Lifecycle', () async {
      const email = 'usecase@test.com';
      const password = 'password123';

      // 1. New user signs up
      await authService.signUp(
        email: email,
        password: password,
        name: 'User One',
        onCreateProfile: (uid, name, email) async {},
      );
      expect(authService.currentUser?.email, email);

      // 2. User signs out
      await authService.signOut();
      expect(authService.currentUser, isNull);

      // 3. User signs back in
      await authService.signIn(email, password);
      expect(authService.currentUser?.email, email);
    });

    test('initial currentUser should be null', () {
      expect(authService.currentUser, isNull);
    });
  });

  group('AuthService - Error Handling (Negative Testing)', () {
    late AuthService errorAuthService;
    late MockFirebaseAuth mockErrorAuth;

    setUp(() {
      mockErrorAuth = MockFirebaseAuth();
      errorAuthService = AuthService(auth: mockErrorAuth);
    });

    test('signIn throws FirebaseAuthException on invalid credentials', () async {
      when(() => mockErrorAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(firebase_auth.FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      ));

      expect(
        () => errorAuthService.signIn('wrong@test.com', 'pass'),
        throwsA(isA<firebase_auth.FirebaseAuthException>()),
      );
    });

    test('signUp throws FirebaseAuthException on weak password', () async {
      when(() => mockErrorAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(firebase_auth.FirebaseAuthException(
        code: 'weak-password',
        message: 'The password provided is too weak.',
      ));

      expect(
        () => errorAuthService.signUp(
          email: 'test@test.com',
          password: '123',
          name: 'Name',
          onCreateProfile: (_, __, ___) async {},
        ),
        throwsA(isA<firebase_auth.FirebaseAuthException>()),
      );
    });
  });
}
