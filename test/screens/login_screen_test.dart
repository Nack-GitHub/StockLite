import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/login_screen.dart';
import '../test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    setupTestGlobals();
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

    expect(find.text('StockLite'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
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

  testWidgets('LoginScreen validation shows errors on empty fields', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const LoginScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
