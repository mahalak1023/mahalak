import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/orders/data/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  // Create a new order
  Future<String> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required DeliveryAddress address,
    String? notes,
    String? storeId,
    String? storeName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to create an order');
      }

      final order = OrderModel(
        orderId: '', // Will be set by Firestore
        userId: user.uid,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: subtotal + deliveryFee,
        status: OrderStatus.pending,
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
        storeId: storeId,
        storeName: storeName,
      );

      final docRef = await _ordersCollection.add(order.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get all orders for current user
  Stream<List<OrderModel>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Get a specific order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Stream a specific order (for real-time updates)
  Stream<OrderModel?> streamOrder(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final updates = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == OrderStatus.delivered) {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await _ordersCollection.doc(orderId).update(updates);
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Delete an order (admin only or for testing)
  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  // Create sample orders for testing
  Future<void> createSampleOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in');
    }

    final sampleAddress = DeliveryAddress(
      street: 'شارع الملك فهد',
      city: 'الرياض',
      building: '123',
      floor: '2',
      apartment: '5',
      landmark: 'بجانب المسجد',
    );

    // Sample order 1 - Delivered
    await createOrder(
      items: [
        OrderItem(
          productId: 'prod1',
          productName: 'تفاح أحمر',
          productImage: 'https://via.placeholder.com/150',
          price: 15.0,
          quantity: 2,
          total: 30.0,
        ),
        OrderItem(
          productId: 'prod2',
          productName: 'موز',
          productImage: 'https://via.placeholder.com/150',
          price: 10.0,
          quantity: 3,
          total: 30.0,
        ),
      ],
      subtotal: 60.0,
      deliveryFee: 10.0,
      address: sampleAddress,
      notes: 'يرجى الاتصال عند الوصول',
      storeId: 'store1',
      storeName: 'محل الفواكه',
    );

    // Sample order 2 - In delivery
    await createOrder(
      items: [
        OrderItem(
          productId: 'prod3',
          productName: 'حليب طازج',
          productImage: 'https://via.placeholder.com/150',
          price: 12.0,
          quantity: 2,
          total: 24.0,
        ),
      ],
      subtotal: 24.0,
      deliveryFee: 10.0,
      address: sampleAddress,
      storeId: 'store2',
      storeName: 'السوبر ماركت',
    );

    // Sample order 3 - Pending
    await createOrder(
      items: [
        OrderItem(
          productId: 'prod4',
          productName: 'خبز طازج',
          productImage: 'https://via.placeholder.com/150',
          price: 5.0,
          quantity: 4,
          total: 20.0,
        ),
      ],
      subtotal: 20.0,
      deliveryFee: 10.0,
      address: sampleAddress,
      storeId: 'store3',
      storeName: 'المخبز',
    );

    print('✅ Sample orders created successfully');
  }
}
