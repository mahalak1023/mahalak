import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/features/stores/data/models/store_model.dart';
import 'package:myapp/Services/image_service.dart';
import 'package:image_picker/image_picker.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  final String _collection = 'stores';
  static const String storeImagesBucket = 'images';
  static const String storeImagesFolder = 'stores';

  // Get all stores
  Stream<List<StoreModel>> getStores() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StoreModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get stores by category
  Stream<List<StoreModel>> getStoresByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StoreModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  // Get single store by ID
  Future<StoreModel?> getStoreById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return StoreModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting store: $e');
      return null;
    }
  }

  // Add a new store
  Future<String?> addStore(StoreModel store) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(store.toJson());
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error adding store: $e');
      return null;
    }
  }

  // Add a new store with image upload to Supabase
  Future<String?> addStoreWithImage({
    required StoreModel store,
    required XFile imageFile,
  }) async {
    try {
      // Upload image to Supabase Storage
      final String fileName = _imageService.generateUniqueFileName(
        imageFile.name,
      );
      final String? imageUrl = await _imageService.uploadImageFromXFile(
        xFile: imageFile,
        fileName: fileName,
        bucket: storeImagesBucket,
        folder: storeImagesFolder,
      );

      if (imageUrl == null) {
        // ignore: avoid_print
        print('Failed to upload image');
        return null;
      }

      // Create store with uploaded image URL
      final storeWithImage = StoreModel(
        id: store.id,
        name: store.name,
        description: store.description,
        imageUrl: imageUrl,
        category: store.category,
        rating: store.rating,
        totalReviews: store.totalReviews,
        isOpen: store.isOpen,
        address: store.address,
        phone: store.phone,
        createdAt: store.createdAt,
      );

      // Add to Firestore
      final docRef = await _firestore
          .collection(_collection)
          .add(storeWithImage.toJson());
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error adding store with image: $e');
      return null;
    }
  }

  // Pick image and upload store
  Future<String?> pickImageAndAddStore({
    required StoreModel store,
    required ImageSource source,
  }) async {
    try {
      // Pick image
      XFile? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await _imageService.pickImageFromGallery();
      } else {
        imageFile = await _imageService.pickImageFromCamera();
      }

      if (imageFile == null) return null;

      // Add store with image
      return await addStoreWithImage(store: store, imageFile: imageFile);
    } catch (e) {
      // ignore: avoid_print
      print('Error in pick image and add store: $e');
      return null;
    }
  }

  // Update store
  Future<bool> updateStore(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error updating store: $e');
      return false;
    }
  }

  // Update store with new image
  Future<bool> updateStoreWithImage({
    required String storeId,
    required XFile imageFile,
    String? oldImageUrl,
  }) async {
    try {
      // Upload new image
      final String fileName = _imageService.generateUniqueFileName(
        imageFile.name,
      );
      final String? newImageUrl = await _imageService.uploadImageFromXFile(
        xFile: imageFile,
        fileName: fileName,
        bucket: storeImagesBucket,
        folder: storeImagesFolder,
      );

      if (newImageUrl == null) return false;

      // Update store with new image URL
      await _firestore.collection(_collection).doc(storeId).update({
        'imageUrl': newImageUrl,
      });

      // Delete old image from Supabase if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await _imageService.deleteImageByUrl(
          imageUrl: oldImageUrl,
          bucket: storeImagesBucket,
        );
      }

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error updating store with image: $e');
      return false;
    }
  }

  // Delete store
  Future<bool> deleteStore(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting store: $e');
      return false;
    }
  }

  // Delete store with its image from Supabase
  Future<bool> deleteStoreWithImage(String id) async {
    try {
      // Get store to retrieve image URL
      final store = await getStoreById(id);

      // Delete from Firestore
      await _firestore.collection(_collection).doc(id).delete();

      // Delete image from Supabase if exists
      if (store != null && store.imageUrl.isNotEmpty) {
        await _imageService.deleteImageByUrl(
          imageUrl: store.imageUrl,
          bucket: storeImagesBucket,
        );
      }

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting store with image: $e');
      return false;
    }
  }

  // Add sample stores (for initial setup)
  Future<void> addSampleStores() async {
    final sampleStores = [
      StoreModel(
        id: '',
        name: 'متجر الخضار الطازجة',
        description: 'أفضل الخضروات الطازجة يومياً',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        category: 'خضروات',
        rating: 4.5,
        totalReviews: 120,
        isOpen: true,
        address: 'شارع الملك فيصل، الرياض',
        phone: '+966501234567',
        createdAt: DateTime.now(),
      ),
      StoreModel(
        id: '',
        name: 'سوبر ماركت النخيل',
        description: 'جميع المنتجات الغذائية تحت سقف واحد',
        imageUrl: 'https://picsum.photos/400/300?random=2',
        category: 'سوبر ماركت',
        rating: 4.2,
        totalReviews: 85,
        isOpen: true,
        address: 'حي النخيل، جدة',
        phone: '+966507654321',
        createdAt: DateTime.now(),
      ),
      StoreModel(
        id: '',
        name: 'مخبز الأصالة',
        description: 'خبز طازج يومياً منذ عام 1990',
        imageUrl: 'https://picsum.photos/400/300?random=3',
        category: 'مخبز',
        rating: 4.8,
        totalReviews: 200,
        isOpen: true,
        address: 'شارع العليا، الرياض',
        phone: '+966509876543',
        createdAt: DateTime.now(),
      ),
      StoreModel(
        id: '',
        name: 'متجر الفواكه المختارة',
        description: 'فواكه مستوردة وطازجة',
        imageUrl: 'https://picsum.photos/400/300?random=4',
        category: 'فواكه',
        rating: 4.6,
        totalReviews: 150,
        isOpen: false,
        address: 'طريق الملك عبدالله، الدمام',
        phone: '+966501122334',
        createdAt: DateTime.now(),
      ),
      StoreModel(
        id: '',
        name: 'بقالة الحي',
        description: 'منتجات غذائية متنوعة بأسعار مناسبة',
        imageUrl: 'https://picsum.photos/400/300?random=5',
        category: 'بقالة',
        rating: 4.0,
        totalReviews: 60,
        isOpen: true,
        address: 'حي الربوة، الرياض',
        phone: '+966505544332',
        createdAt: DateTime.now(),
      ),
    ];

    for (var store in sampleStores) {
      await addStore(store);
    }
  }
}
