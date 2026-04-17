import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:stock_lite/services/auth_service.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('AuthService Tests', () {
    test('initial currentUser should be null', () {
      expect(authService.currentUser, isNull);
    });

    test('signIn authenticates the user successfully', () async {
      // Create a mock user in the fake auth
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      final specificMockAuth = MockFirebaseAuth(mockUser: mockUser);
      final specificAuthService = AuthService(auth: specificMockAuth);
      
      expect(specificAuthService.currentUser, isNull);
      
      final credential = await specificAuthService.signIn('test@example.com', 'password123');
      
      expect(credential!.user, isNotNull);
      expect(credential.user?.uid, 'user123');
      expect(specificAuthService.currentUser?.uid, 'user123');
    });

    test('signUp creates user successfully', () async {
      final credential = await authService.signUp(
        email: 'new@example.com', 
        password: 'password123',
        name: 'New User',
        onCreateProfile: (uid, name, email) async {},
      );
      
      expect(credential!.user, isNotNull);
      
      // Note: firebase_auth_mocks automatically signs in upon signing up
      expect(authService.currentUser, isNotNull);
    });

    test('signOut signs out the user successfully', () async {
      // Mock an existing signed-in user
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final specificMockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final specificAuthService = AuthService(auth: specificMockAuth);
      
      expect(specificAuthService.currentUser, isNotNull);

      await specificAuthService.signOut();

      expect(specificAuthService.currentUser, isNull);
    });
  });
}
