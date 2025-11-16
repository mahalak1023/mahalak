class ProductModel {
  final String id;
  final String name;
  final String store;
  final double price;
  final double? oldPrice;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.store,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      store: data['store'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (data['oldPrice'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'store': store,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
    };
  }
}
