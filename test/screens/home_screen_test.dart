import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/home_screen.dart';
import 'package:stock_lite/models/product.dart';
import '../test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    setupTestGlobals();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();

    final mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.empty());
    when(() => mockDatabaseService.getProducts(any())).thenAnswer((_) => Stream.value([]));
  });

  testWidgets('HomeScreen renders welcome message and stats', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const HomeScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    expect(find.text('Product Catalog'), findsOneWidget);
    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('Your inventory is empty'), findsOneWidget);
  });

  testWidgets('HomeScreen displays products from database', (WidgetTester tester) async {
    final products = [
      createTestProduct(id: '1', name: 'Product A'),
      createTestProduct(id: '2', name: 'Product B'),
    ];

    when(() => mockDatabaseService.getProducts(any())).thenAnswer((_) => Stream.value(products));

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const HomeScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    await tester.pumpAndSettle();

    expect(find.text('Product A'), findsOneWidget);
    expect(find.text('Product B'), findsOneWidget);
  });
}
