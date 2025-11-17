import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id; // Firestore document id
  final String productId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final double total;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
  }) : total = price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'total': price * quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CartItemModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final price = (data['price'] ?? 0).toDouble();
    final quantity = (data['quantity'] ?? 0) as int;
    return CartItemModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      price: price,
      quantity: quantity,
    );
  }
}
