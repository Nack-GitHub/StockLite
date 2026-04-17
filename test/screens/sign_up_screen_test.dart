import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/sign_up_screen.dart';
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

  testWidgets('SignUpScreen shows validation errors', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const SignUpScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });
}
