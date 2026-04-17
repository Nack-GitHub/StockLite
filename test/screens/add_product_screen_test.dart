import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_lite/screens/add_product_screen.dart';
import '../test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    setupTestGlobals();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
  });

  testWidgets('AddProductScreen renders all form fields', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const AddProductScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('PRODUCT DESIGNATION'), findsOneWidget);
    expect(find.text('SKU / ID'), findsOneWidget);
    expect(find.text('INITIAL STOCK LEVEL'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('Add Product to Inventory'), findsOneWidget);
  });

  testWidgets('AddProductScreen shows validation errors for empty fields', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpStockLite(
        const AddProductScreen(),
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      );
    });

    final button = find.text('Add Product to Inventory');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a product name'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
  });
}
