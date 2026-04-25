import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock_lite/models/product.dart';
import 'package:stock_lite/services/database_service.dart';

void main() {
  late DatabaseService databaseService;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService(firestore: fakeFirestore);
  });

  group('DatabaseService - Advanced Testing', () {
    final testUid = 'user123';

    test('BVA & EP: updateProductStock status calculation', () async {
      final docRef = await fakeFirestore.collection('products').add({
        'name': 'BVA Test',
        'sku': 'BVA-1',
        'category': 'Tests',
        'stock': 50,
        'status': 'In Stock',
        'ownerId': testUid,
      });

      final testCases = [
        {'stock': 0, 'expected': 'Out of Stock', 'desc': 'Boundary: 0 (Out of Stock)'},
        {'stock': 1, 'expected': 'Low Stock', 'desc': 'Boundary: 1 (Low Stock Lower)'},
        {'stock': 9, 'expected': 'Low Stock', 'desc': 'Boundary: 9 (Low Stock Upper)'},
        {'stock': 10, 'expected': 'In Stock', 'desc': 'Boundary: 10 (In Stock Boundary)'},
      ];

      for (var tc in testCases) {
        await databaseService.updateProductStock(docRef.id, tc['stock'] as int);
        final updatedDoc = await docRef.get();
        expect(
          updatedDoc.data()?['status'], 
          tc['expected'], 
          reason: tc['desc'] as String,
        );
      }
    });

    test('Decision Table: Stock Status Logic', () async {
      // Logic Table:
      // Condition: Stock == 0 | Stock < 10 | Stock >= 10
      // Action: Out of Stock | Low Stock   | In Stock
      
      final product = await fakeFirestore.collection('products').add({
        'name': 'Decision Table Test',
        'ownerId': testUid,
      });

      // Rule 1: Stock 0
      await databaseService.updateProductStock(product.id, 0);
      expect((await product.get()).data()?['status'], 'Out of Stock');

      // Rule 2: Stock 5 (between 1-9)
      await databaseService.updateProductStock(product.id, 5);
      expect((await product.get()).data()?['status'], 'Low Stock');

      // Rule 3: Stock 20 (>= 10)
      await databaseService.updateProductStock(product.id, 20);
      expect((await product.get()).data()?['status'], 'In Stock');
    });

    test('State Transition: Product Stock lifecycle', () async {
      final docRef = await fakeFirestore.collection('products').add({
        'name': 'Lifecycle Test',
        'stock': 15,
        'status': 'In Stock',
        'ownerId': testUid,
      });

      // Transition: In Stock -> Low Stock
      await databaseService.updateProductStock(docRef.id, 5);
      expect((await docRef.get()).data()?['status'], 'Low Stock');

      // Transition: Low Stock -> Out of Stock
      await databaseService.updateProductStock(docRef.id, 0);
      expect((await docRef.get()).data()?['status'], 'Out of Stock');

      // Transition: Out of Stock -> In Stock
      await databaseService.updateProductStock(docRef.id, 100);
      expect((await docRef.get()).data()?['status'], 'In Stock');
    });

    test('addProduct adds a product to the correct collection', () async {
      final product = Product(
        id: '',
        name: 'Test Product',
        sku: 'TEST-123',
        category: 'Tests',
        stock: 10,
        status: 'In Stock',
        imageUrl: '',
        ownerId: testUid,
      );

      await databaseService.addProduct(product);

      final snapshot = await fakeFirestore.collection('products').get();
      expect(snapshot.docs.isNotEmpty, true);
      final docData = snapshot.docs.firstWhere((doc) => doc.data()['name'] == 'Test Product').data();
      
      expect(docData['name'], 'Test Product');
      expect(docData['sku'], 'TEST-123');
      expect(docData['ownerId'], testUid);
    });

    test('getProducts retrieves only products matching ownerId', () async {
      await fakeFirestore.collection('products').add({
        'name': 'Owned Product',
        'ownerId': testUid,
      });

      await fakeFirestore.collection('products').add({
        'name': 'Other Product',
        'ownerId': 'other_user',
      });

      final products = await databaseService.getProducts(testUid).first;
      
      expect(products.any((p) => p.name == 'Owned Product'), true);
      expect(products.any((p) => p.name == 'Other Product'), false);
    });
  });

  group('DatabaseService - Error Handling (Negative Testing)', () {
    test('updateProductStock throws error on non-existent ID', () async {
      // update() on a non-existent document in Firestore/fake_firestore
      // should throw an exception.
      expect(
        () => databaseService.updateProductStock('non-existent-id', 10),
        throwsException,
      );
    });
  });
}
