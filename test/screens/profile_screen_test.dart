import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/profile_screen.dart';
import '../test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;
  late MockUser mockUser;

  setUp(() {
    setupTestGlobals();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.empty());
    when(() => mockDatabaseService.getUserProfile(any())).thenAnswer((_) => Stream.value({'name': 'Test User'}));
    when(() => mockDatabaseService.getProducts(any())).thenAnswer((_) => Stream.value([]));
  });

  testWidgets('ProfileScreen renders user information', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const ProfileScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);
  });

  testWidgets('ProfileScreen logout button triggers signOut', (WidgetTester tester) async {
    when(() => mockAuthService.signOut()).thenAnswer((_) async => {});

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const ProfileScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
      await tester.pumpAndSettle();
    });

    final logoutButton = find.text('Sign Out');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    verify(() => mockAuthService.signOut()).called(1);
  });
}
