import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/sign_up_screen.dart';
import 'package:stock_lite/widgets/stock_lite_input.dart';
import '../test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    setupTestGlobals();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
    
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.empty());
  });

  testWidgets('SignUpScreen renders title and form fields', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const SignUpScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    expect(find.text('Create Account'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Email, Password, Confirm Password
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('SignUpScreen validation follows BVA and EP patterns', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const SignUpScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    final signUpButton = find.text('Sign Up');
    final nameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);
    final passwordField = find.byType(TextFormField).at(2);
    final confirmField = find.byType(TextFormField).at(3);

    // --- 1. Equivalence Partitioning (EP) for Email ---
    // Invalid Partition: Empty
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);

    // Invalid Partition: Format
    await tester.enterText(emailField, 'invalid-email');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Valid Partition: Valid Email
    await tester.enterText(emailField, 'test@example.com');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsNothing);

    // --- 2. Boundary Value Analysis (BVA) for Password Length (8-16) ---
    // Using 3-point strategy: -1, On, +1

    // Lower Boundary (8): Test 7, 8, 9
    // 7 (Lower Out)
    await tester.enterText(passwordField, 'Pass12!'); 
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);

    // 8 (Lower On)
    await tester.enterText(passwordField, 'Pass123!');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters'), findsNothing);

    // 9 (Lower In)
    await tester.enterText(passwordField, 'Pass1234!');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters'), findsNothing);

    // Upper Boundary (16): Test 15, 16, 17
    // 15 (Upper In)
    await tester.enterText(passwordField, 'P' + 'a' * 12 + '1!');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must not exceed 16 characters'), findsNothing);

    // 16 (Upper On)
    await tester.enterText(passwordField, 'P' + 'a' * 13 + '1!');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must not exceed 16 characters'), findsNothing);

    // 17 (Upper Out)
    await tester.enterText(passwordField, 'P' + 'a' * 14 + '1!');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must not exceed 16 characters'), findsOneWidget);

    // --- 3. EP for Password Complexity ---
    // Invalid Partition: No Uppercase/Special
    await tester.enterText(passwordField, 'password123');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Include uppercase, lowercase, number, and special character'), findsOneWidget);

    // --- 4. Logic Partition: Confirm Password ---
    await tester.enterText(passwordField, 'Password123!');
    await tester.enterText(confirmField, 'Different123!');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('SignUpScreen requires Terms of Service agreement', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const SignUpScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    // Fill valid data
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'ValidPass123!');
    await tester.enterText(find.byType(TextFormField).at(3), 'ValidPass123!');
    
    // Tap Sign Up without checking Terms
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Should show requirement dialog
    expect(find.text('Precision Requirement'), findsOneWidget);
    expect(find.text('Please agree to total precision terms before proceeding.'), findsOneWidget);
    
    // Close dialog
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Precision Requirement'), findsNothing);
  });

  testWidgets('SignUpScreen calls signUp on valid submission', (WidgetTester tester) async {
    when(() => mockAuthService.signUp(
      email: any(named: 'email'),
      password: any(named: 'password'),
      name: any(named: 'name'),
      onCreateProfile: any(named: 'onCreateProfile'),
    )).thenAnswer((_) async {});

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const SignUpScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    // Fill valid data
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'ValidPass123!');
    await tester.enterText(find.byType(TextFormField).at(3), 'ValidPass123!');
    
    // Agree to terms
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Tap Sign Up
    await tester.tap(find.text('Sign Up'));
    await tester.pump(); // Start signup

    verify(() => mockAuthService.signUp(
      email: 'john@example.com',
      password: 'ValidPass123!',
      name: 'John Doe',
      onCreateProfile: any(named: 'onCreateProfile'),
    )).called(1);
  });
}
