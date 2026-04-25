import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_lite/screens/add_product_screen.dart';
import 'package:stock_lite/models/product.dart';
import 'package:stock_lite/widgets/stock_lite_input.dart';
import '../test_helpers.dart';

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Test User';
}

void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;

  setUpAll(() {
    registerFallbackValue(createTestProduct());
  });

  setUp(() {
    setupTestGlobals();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
    
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.empty());
    when(() => mockAuthService.currentUser).thenReturn(FakeUser());
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

  group('AddProductScreen - Black-Box Testing (BVA/EP)', () {
    testWidgets('Validation: Empty Name and SKU (EP: Invalid Partition)', (WidgetTester tester) async {
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

    testWidgets('Validation: Name Length (BVA)', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpStockLite(
          const AddProductScreen(),
          authService: mockAuthService,
          databaseService: mockDatabaseService,
        );
      });

      final nameField = find.byType(StockLiteInput).first;
      
      // EP: Valid Name
      await tester.enterText(nameField, 'Valid Product');
      await tester.tap(find.text('Add Product to Inventory'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a product name'), findsNothing);
    });
  });

  group('AddProductScreen - State Transition Testing (Stock Status)', () {
    testWidgets('Stock transitions: 0 (Out of Stock), 1 (Low Stock), 10 (In Stock)', (WidgetTester tester) async {
      when(() => mockDatabaseService.addProduct(any())).thenAnswer((_) async => {});

      Future<void> setupForm() async {
        await tester.pumpWidget(Container());
        await tester.runAsync(() async {
          await tester.pumpStockLite(
            const AddProductScreen(),
            authService: mockAuthService,
            databaseService: mockDatabaseService,
          );
        });
        await tester.enterText(find.byType(StockLiteInput).at(0), 'Transition Test');
        await tester.enterText(find.byType(StockLiteInput).at(1), 'T-001');
      }

      // --- State: 0 (Out of Stock) ---
      await setupForm();
      // Initial is 10, remove 10 times
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.remove));
      }
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      
      await tester.tap(find.text('Add Product to Inventory'));
      await tester.pumpAndSettle();

      verify(() => mockDatabaseService.addProduct(any(
        that: isA<Product>().having((Product p) => p.status, 'status', 'Out of Stock')
      ))).called(1);

      // --- State: 1 (Low Stock) ---
      await setupForm();
      // Initial is 10, remove 9 times
      for (int i = 0; i < 9; i++) {
        await tester.tap(find.byIcon(Icons.remove));
      }
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Add Product to Inventory'));
      await tester.pumpAndSettle();

      verify(() => mockDatabaseService.addProduct(any(
        that: isA<Product>().having((Product p) => p.status, 'status', 'Low Stock')
      ))).called(1);

      // --- State: 10 (In Stock) ---
      await setupForm();
      // Initial is 10
      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.text('Add Product to Inventory'));
      await tester.pumpAndSettle();

      verify(() => mockDatabaseService.addProduct(any(
        that: isA<Product>().having((Product p) => p.status, 'status', 'In Stock')
      ))).called(1);
    });
  });
}
