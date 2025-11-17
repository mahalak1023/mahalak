import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/home/data/models/store_model.dart';
import 'package:myapp/features/product/data/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      developer.log('Error getting products', name: 'myapp.firestore', error: e, stackTrace: s);
      return [];
    }
  }

  Future<List<StoreModel>> getStores() async {
    try {
      final snapshot = await _db.collection('stores').get();
      return snapshot.docs
          .map((doc) => StoreModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      developer.log('Error getting stores', name: 'myapp.firestore', error: e, stackTrace: s);
      return [];
    }
  }

  Future<void> addSampleData() async {
    final productsCollection = _db.collection('products');
    final storesCollection = _db.collection('stores');

    // Check if data already exists
    final productsSnapshot = await productsCollection.limit(1).get();
    if (productsSnapshot.docs.isNotEmpty) {
      developer.log('Sample data already exists.', name: 'myapp.firestore');
      return;
    }

    developer.log('Adding sample data to Firestore...', name: 'myapp.firestore');

    final List<ProductModel> products = [
      ProductModel(
        id: '1',
        name: "جبنة بيضاء بلدي - 1 كغ",
        store: "سوبر ماركت الأمانة",
        price: 75.0,
        oldPrice: 90.0,
        imageUrl: "https://picsum.photos/seed/cheese/400/400",
      ),
      ProductModel(
        id: '2',
        name: "خبز أسمر طازج - كيس",
        store: "مخبز وحلويات النجاح",
        price: 5.0,
        imageUrl: "https://picsum.photos/seed/bread/400/400",
      ),
      ProductModel(
        id: '3',
        name: "دجاج كامل طازج - 900غ",
        store: "ملحمة أبو أحمد",
        price: 28.0,
        oldPrice: 32.0,
        imageUrl: "https://picsum.photos/seed/chicken/400/400",
      ),
      ProductModel(
        id: '4',
        name: "زيت زيتون بكر - 500مل",
        store: "سوبر ماركت الأمانة",
        price: 45.0,
        imageUrl: "https://picsum.photos/seed/olive/400/400",
      ),
    ];

    final List<StoreModel> stores = [
      StoreModel(
        id: '1',
        name: "سوبر ماركت الأمانة",
        category: "بقالة عامة",
        deliveryTime: "30-45 دقيقة",
        rating: 4.5,
      ),
      StoreModel(
        id: '2',
        name: "مخبز وحلويات النجاح",
        category: "مخبوزات",
        deliveryTime: "20-30 دقيقة",
        rating: 4.8,
      ),
      StoreModel(
        id: '3',
        name: "ملحمة أبو أحمد",
        category: "لحوم ودواجن",
        deliveryTime: "45-60 دقيقة",
        rating: 4.2,
      ),
    ];

    for (var product in products) {
      await productsCollection.add(product.toMap());
    }

    for (var store in stores) {
      await storesCollection.add(store.toMap());
    }

    developer.log('Sample data added.', name: 'myapp.firestore');
  }
}
