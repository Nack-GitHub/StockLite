import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/login_screen.dart';
import 'package:stock_lite/services/local_storage_service.dart';
import '../test_helpers.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    setupTestGlobals();
    LocalStorageService.reset();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();

    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => Stream.empty());
  });

  testWidgets('LoginScreen renders logo, fields and buttons', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    expect(find.text('StockLite'), findsWidgets);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.textContaining('Sign up'), findsOneWidget);
  });

  testWidgets('LoginScreen toggles password visibility', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
    expect(visibilityIcon, findsOneWidget);

    await tester.tap(visibilityIcon);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('LoginScreen validation follows BVA and EP patterns', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    final signInButton = find.text('Sign In');
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    // --- 1. Equivalence Partitioning (EP) for Email ---
    // Invalid Partition: Empty
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);

    // Invalid Partition: Format
    await tester.enterText(emailField, 'invalid-email');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Valid Partition: Valid Email
    await tester.enterText(emailField, 'test@example.com');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsNothing);

    // --- 2. Boundary Value Analysis (BVA) for Password Length (8-16) ---
    // Using 3-point strategy: -1, On, +1

    // Lower Boundary (8): Test 7, 8, 9
    // 7 (Lower Out)
    await tester.enterText(passwordField, 'short7!'); 
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);

    // 8 (Lower On)
    await tester.enterText(passwordField, 'pass8!!!');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters'), findsNothing);

    // 9 (Lower In)
    await tester.enterText(passwordField, 'pass9!!!!');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters'), findsNothing);

    // Upper Boundary (16): Test 15, 16, 17
    // 15 (Upper In)
    await tester.enterText(passwordField, 'p' * 15);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must not exceed 16 characters'), findsNothing);

    // 16 (Upper On)
    await tester.enterText(passwordField, 'p' * 16);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must not exceed 16 characters'), findsNothing);

    // 17 (Upper Out)
    await tester.enterText(passwordField, 'p' * 17);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must not exceed 16 characters'), findsOneWidget);
  });

  testWidgets('LoginScreen loads saved email from local storage', (
    WidgetTester tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', 'saved@example.com');

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
      await tester.pumpAndSettle();
    });

    final emailField = find.byType(TextFormField).at(0);
    final controller = tester.widget<TextFormField>(emailField).controller;
    expect(controller?.text, 'saved@example.com');
  });

  testWidgets('LoginScreen shows dialog on failed login', (
    WidgetTester tester,
  ) async {
    when(() => mockAuthService.signIn(any(), any())).thenThrow(
      Exception('Invalid credentials'),
    );

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Login Failed'), findsOneWidget);
    expect(find.text('Exception: Invalid credentials'), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to signup on link tap', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    await tester.tap(find.textContaining('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Route: /signup'), findsOneWidget);
  });

  testWidgets('LoginScreen calls signIn on valid submission', (
    WidgetTester tester,
  ) async {
    when(() => mockAuthService.signIn(any(), any())).thenAnswer((_) async {});

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    await tester.enterText(find.byType(TextFormField).at(0), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'ValidPass123!');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    verify(() => mockAuthService.signIn('john@example.com', 'ValidPass123!'))
        .called(1);
  });
}
