class StoreModel {
  final String id;
  final String name;
  final String category;
  final String deliveryTime;
  final double rating;

  StoreModel({
    required this.id,
    required this.name,
    required this.category,
    required this.deliveryTime,
    required this.rating,
  });

  factory StoreModel.fromMap(String id, Map<String, dynamic> data) {
    return StoreModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      deliveryTime: data['deliveryTime'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'deliveryTime': deliveryTime,
      'rating': rating,
    };
  }
}
