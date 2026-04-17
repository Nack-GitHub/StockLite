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

  testWidgets('ProductDetailScreen buttons trigger stock updates', (WidgetTester tester) async {
    when(() => mockDatabaseService.updateProductStock(any(), any())).thenAnswer((_) async => {});

    await tester.runAsync(() async {
      await tester.pumpStockLite(
        ProductDetailScreen(product: testProduct),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
      await tester.pumpAndSettle();
    });

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    verify(() => mockDatabaseService.updateProductStock('1', 51)).called(1);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    verify(() => mockDatabaseService.updateProductStock('1', 50)).called(1);
  });
}
