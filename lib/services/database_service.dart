import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _productsRef => _db.collection('products');
  CollectionReference get _usersRef => _db.collection('users');

  // GET PRODUCTS (Stream)
  Stream<List<Product>> get products {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // ADD PRODUCT
  Future<void> addProduct(Product product) async {
    await _productsRef.add(product.toMap());
  }

  // UPDATE PRODUCT STOCK
  Future<void> updateProductStock(String id, int newStock) async {
    await _productsRef.doc(id).update({
      'stock': newStock,
      'status': newStock == 0 ? 'Out of Stock' : (newStock < 10 ? 'Low Stock' : 'In Stock'),
    });
  }

  // DELETE PRODUCT
  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }

  // USER PROFILE
  Future<void> createUserProfile(String uid, String name, String email) async {
    await _usersRef.doc(uid).set({
      'name': name,
      'email': email,
      'role': 'Administrator',
      'hub': 'SF Hub',
      'stats': {
        'itemsTracked': 0,
        'monthlyReports': 0,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>?> getUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) => doc.data() as Map<String, dynamic>?);
  }
}
