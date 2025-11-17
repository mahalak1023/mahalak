import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  /// Default storage bucket name for images
  static const String defaultBucket = 'images';

  /// Pick an image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      // ignore: avoid_print
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick an image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      // ignore: avoid_print
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Upload image to Supabase Storage from file path (for non-web platforms)
  /// Returns the public URL of the uploaded image
  Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String bucket = defaultBucket,
    String? folder,
  }) async {
    try {
      // Construct the storage path
      final String path = folder != null ? '$folder/$fileName' : fileName;

      // Upload to Supabase Storage
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getContentType(fileName),
            ),
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload image from XFile (picked image)
  Future<String?> uploadImageFromXFile({
    required XFile xFile,
    required String fileName,
    String bucket = defaultBucket,
    String? folder,
  }) async {
    try {
      // Construct the storage path
      final String path = folder != null ? '$folder/$fileName' : fileName;

      // Read file as bytes
      final Uint8List bytes = await xFile.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getContentType(fileName),
            ),
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading image from XFile: $e');
      return null;
    }
  }

  /// Delete image from Supabase Storage
  Future<bool> deleteImage({
    required String fileName,
    String bucket = defaultBucket,
    String? folder,
  }) async {
    try {
      final String path = folder != null ? '$folder/$fileName' : fileName;

      await _supabase.storage.from(bucket).remove([path]);

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Delete image by URL
  Future<bool> deleteImageByUrl({
    required String imageUrl,
    String bucket = defaultBucket,
  }) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.pathSegments.last;

      await _supabase.storage.from(bucket).remove([path]);

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting image by URL: $e');
      return false;
    }
  }

  /// List all images in a folder
  Future<List<FileObject>> listImages({
    String bucket = defaultBucket,
    String? folder,
  }) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(bucket)
          .list(path: folder);

      return files;
    } catch (e) {
      // ignore: avoid_print
      print('Error listing images: $e');
      return [];
    }
  }

  /// Generate a unique file name with timestamp
  String generateUniqueFileName(String originalFileName) {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = originalFileName.split('.').last;
    return 'img_${timestamp}.$extension';
  }

  /// Get content type based on file extension
  String _getContentType(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }

  /// Complete workflow: Pick and upload image
  /// Returns the public URL of the uploaded image
  Future<String?> pickAndUploadImage({
    required ImageSource source,
    String bucket = defaultBucket,
    String? folder,
  }) async {
    try {
      // Pick image
      XFile? pickedFile;
      if (source == ImageSource.gallery) {
        pickedFile = await pickImageFromGallery();
      } else {
        pickedFile = await pickImageFromCamera();
      }

      if (pickedFile == null) return null;

      // Generate unique file name
      final String fileName = generateUniqueFileName(pickedFile.name);

      // Upload image
      final String? publicUrl = await uploadImageFromXFile(
        xFile: pickedFile,
        fileName: fileName,
        bucket: bucket,
        folder: folder,
      );

      return publicUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error in pick and upload workflow: $e');
      return null;
    }
  }

  /// Create a storage bucket if it doesn't exist
  Future<bool> createBucket(String bucketName) async {
    try {
      await _supabase.storage.createBucket(
        bucketName,
        const BucketOptions(public: true),
      );
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating bucket (may already exist): $e');
      return false;
    }
  }
}
