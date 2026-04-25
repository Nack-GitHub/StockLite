import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/product_detail_screen.dart';
import 'package:stock_lite/models/product.dart';
import '../test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;
  late Product testProduct;

  setUp(() {
    setupTestGlobals();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
    
    testProduct = createTestProduct(id: '1', name: 'Original Product', stock: 50);

    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.empty());
  });

  testWidgets('ProductDetailScreen renders product info and stock controls', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        ProductDetailScreen(product: testProduct),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
      await tester.pumpAndSettle();
    });

    expect(find.text('Original Product'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  group('ProductDetailScreen - State Transition Testing (Stock)', () {
    testWidgets('Stock updates trigger state transitions in UI', (WidgetTester tester) async {
      when(() => mockDatabaseService.updateProductStock(any(), any())).thenAnswer((_) async => {});

      // Start with stock 2 (Low Stock)
      final p2 = createTestProduct(id: '2', stock: 2);

      await tester.runAsync(() async {
        await tester.pumpStockLite(
          ProductDetailScreen(product: p2),
          authService: mockAuthService,
          databaseService: mockDatabaseService,
        );
        await tester.pumpAndSettle();
      });

      expect(find.text('LOW STOCK'), findsOneWidget);

      // --- Transition: Low Stock -> Out of Stock (2 -> 0) ---
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      verify(() => mockDatabaseService.updateProductStock('2', 1)).called(1);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('OUT OF STOCK'), findsOneWidget);
      verify(() => mockDatabaseService.updateProductStock('2', 0)).called(1);

      // --- Transition: Out of Stock -> Low Stock (0 -> 1) ---
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('LOW STOCK'), findsOneWidget);
      // It was called once before during "down", now it's the 2nd time
      verify(() => mockDatabaseService.updateProductStock('2', 1)).called(1);

      // --- Transition: Low Stock -> In Stock (1 -> 10) ---
      for (int i = 2; i <= 10; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        verify(() => mockDatabaseService.updateProductStock('2', i)).called(1);
      }

      expect(find.text('10'), findsOneWidget);
      expect(find.text('IN STOCK'), findsOneWidget);
    });
  });
}
