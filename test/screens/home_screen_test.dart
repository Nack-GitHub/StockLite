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

  group('HomeScreen - Black-Box Testing', () {
    testWidgets('Use Case: Search for a specific product by name', (WidgetTester tester) async {
      final products = [
        createTestProduct(id: '1', name: 'MacBook Pro', category: 'Electronics'),
        createTestProduct(id: '2', name: 'Standing Desk', category: 'Furniture'),
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

      // Search for "MacBook"
      await tester.enterText(find.byType(TextField), 'MacBook');
      await tester.pumpAndSettle();

      expect(find.text('MacBook Pro'), findsOneWidget);
      expect(find.text('Standing Desk'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('MacBook Pro'), findsOneWidget);
      expect(find.text('Standing Desk'), findsOneWidget);
    });

    testWidgets('Decision Table: Filter by Category (Electronics vs Furniture)', (WidgetTester tester) async {
      final products = [
        createTestProduct(id: '1', name: 'iPhone', category: 'Electronics'),
        createTestProduct(id: '2', name: 'Sofa', category: 'Furniture'),
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

      // Search "Electronics" (EP: Category Filter)
      await tester.enterText(find.byType(TextField), 'Electronics');
      await tester.pumpAndSettle();

      expect(find.text('iPhone'), findsOneWidget);
      expect(find.text('Sofa'), findsNothing);
    });
  });
}
