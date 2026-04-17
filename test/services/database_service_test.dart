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

  group('DatabaseService Tests', () {
    final testUid = 'user123';
    
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
      expect(snapshot.docs.length, 1);
      final docData = snapshot.docs.first.data();
      
      expect(docData['name'], 'Test Product');
      expect(docData['sku'], 'TEST-123');
      expect(docData['ownerId'], testUid);
      expect(docData['stock'], 10);
    });

    test('getProducts retrieves only products matching ownerId', () async {
      // Add a product for the test user
      await fakeFirestore.collection('products').add({
        'name': 'Test Product 1',
        'sku': 'TEST-1',
        'category': 'Tests',
        'stock': 5,
        'status': 'Low Stock',
        'imageUrl': '',
        'ownerId': testUid,
      });

      // Add a product for a different user
      await fakeFirestore.collection('products').add({
        'name': 'Test Product 2',
        'sku': 'TEST-2',
        'category': 'Tests',
        'stock': 15,
        'status': 'In Stock',
        'imageUrl': '',
        'ownerId': 'other_user456',
      });

      final productsStream = databaseService.getProducts(testUid);
      
      final products = await productsStream.first;
      
      expect(products.length, 1);
      expect(products.first.name, 'Test Product 1');
      expect(products.first.ownerId, testUid);
    });

    test('updateProductStock updates stock and automatically adjusts status', () async {
      final docRef = await fakeFirestore.collection('products').add({
        'name': 'Test Product',
        'sku': 'TEST-1',
        'category': 'Tests',
        'stock': 50,
        'status': 'In Stock',
        'imageUrl': '',
        'ownerId': testUid,
      });

      await databaseService.updateProductStock(docRef.id, 5);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?['stock'], 5);
      expect(updatedDoc.data()?['status'], 'Low Stock');

      await databaseService.updateProductStock(docRef.id, 0);

      final outOfStockDoc = await docRef.get();
      expect(outOfStockDoc.data()?['stock'], 0);
      expect(outOfStockDoc.data()?['status'], 'Out of Stock');
    });

    test('deleteProduct removes product from collection', () async {
      final docRef = await fakeFirestore.collection('products').add({
        'name': 'Test Product',
        'sku': 'TEST-1',
        'category': 'Tests',
        'stock': 50,
        'status': 'In Stock',
        'imageUrl': '',
        'ownerId': testUid,
      });

      await databaseService.deleteProduct(docRef.id);

      final snapshot = await fakeFirestore.collection('products').get();
      expect(snapshot.docs.isEmpty, true);
    });
  });
}
