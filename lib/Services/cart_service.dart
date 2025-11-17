import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/features/cart/data/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userCartCollection(String uid) {
    return _firestore.collection('carts').doc(uid).collection('items');
  }

  // Stream current user's cart items
  Stream<List<CartItemModel>> getCartStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _userCartCollection(user.uid).snapshots().map((snap) {
      return snap.docs.map((d) => CartItemModel.fromDoc(d)).toList();
    });
  }

  // Add or increment item in cart
  Future<void> addOrIncrementItem({
    required String productId,
    required String name,
    String? imageUrl,
    required double price,
    int quantity = 1,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final itemsRef = _userCartCollection(user.uid);
    final existing = await itemsRef
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = (doc.data()['quantity'] ?? 0) as int;
      await doc.reference.update({
        'quantity': currentQty + quantity,
        'updatedAt': FieldValue.serverTimestamp(),
        'total': (currentQty + quantity) * price,
      });
    } else {
      await itemsRef.add({
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'total': price * quantity,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update quantity
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = _userCartCollection(user.uid).doc(itemId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final price = (doc.data()?['price'] ?? 0).toDouble();
    await docRef.update({
      'quantity': newQuantity,
      'total': price * newQuantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove item
  Future<void> removeItem(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _userCartCollection(user.uid).doc(itemId).delete();
  }

  // Clear cart
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final batch = _firestore.batch();
    final snapshot = await _userCartCollection(user.uid).get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Get cart total
  Future<double> getCartTotal() async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;
    final snapshot = await _userCartCollection(user.uid).get();
    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['total'] ?? 0).toDouble();
    }
    return total;
  }
}
