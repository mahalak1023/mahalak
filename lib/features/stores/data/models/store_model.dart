class StoreModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int totalReviews;
  final bool isOpen;
  final String address;
  final String phone;
  final DateTime createdAt;

  StoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.isOpen,
    required this.address,
    required this.phone,
    required this.createdAt,
  });

  // Convert Firestore document to StoreModel
  factory StoreModel.fromJson(Map<String, dynamic> json, String docId) {
    return StoreModel(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isOpen: json['isOpen'] ?? false,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert StoreModel to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'totalReviews': totalReviews,
      'isOpen': isOpen,
      'address': address,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
