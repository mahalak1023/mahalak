import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DeliveryAddress address;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final String? storeId;
  final String? storeName;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.address,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.storeId,
    this.storeName,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'address': address.toMap(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'storeId': storeId,
      'storeName': storeName,
    };
  }

  // Create from Firestore document
  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      orderId: documentId,
      userId: map['userId'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      address: DeliveryAddress.fromMap(
        map['address'] as Map<String, dynamic>? ?? {},
      ),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      storeId: map['storeId'],
      storeName: map['storeName'],
    );
  }

  // Create a copy with updated fields
  OrderModel copyWith({
    String? orderId,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DeliveryAddress? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    String? storeId,
    String? storeName,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
    );
  }
}

// Order item (product in the order)
class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0).toDouble(),
    );
  }
}

// Delivery address
class DeliveryAddress {
  final String street;
  final String city;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  DeliveryAddress({
    required this.street,
    required this.city,
    this.building,
    this.floor,
    this.apartment,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      building: map['building'],
      floor: map['floor'],
      apartment: map['apartment'],
      landmark: map['landmark'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}

// Order status enum
enum OrderStatus {
  pending, // قيد الانتظار
  confirmed, // تم التأكيد
  preparing, // قيد التحضير
  readyForPickup, // جاهز للاستلام
  outForDelivery, // في الطريق
  delivered, // تم التوصيل
  cancelled, // ملغي
}

// Extension for Arabic status names
extension OrderStatusExtension on OrderStatus {
  String get arabicName {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.readyForPickup:
        return 'جاهز للاستلام';
      case OrderStatus.outForDelivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }
}
