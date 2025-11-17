# Supabase Image Storage Setup Guide

## ✅ What's Already Configured

### 1. Environment Variables (`.env`)
```env
SUPABASE_URL=https://cpihytlerednyhqjkxne.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
```

### 2. Dependencies Installed
- `supabase_flutter: ^2.0.0`
- `image_picker: ^1.0.4`
- `cloud_firestore: ^4.8.0`
- `firebase_core: ^2.12.0`

### 3. Initialized in `main.dart`
```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? '',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
);
```

## 📁 Services Created

### `lib/Services/image_service.dart`
Handles all image operations with Supabase Storage:
- Pick images from gallery/camera
- Upload to Supabase Storage
- Delete images
- Generate unique filenames
- List images in folders

### `lib/Services/store_service.dart`
Complete store CRUD with Supabase image integration:
- `addStoreWithImage()` - Upload image to Supabase, then create store
- `updateStoreWithImage()` - Replace old image with new one
- `deleteStoreWithImage()` - Delete store and its image
- `pickImageAndAddStore()` - Pick image and add store in one call

## 🗄️ Supabase Storage Setup

### Step 1: Create Storage Bucket
1. Go to https://cpihytlerednyhqjkxne.supabase.co
2. Click **Storage** in sidebar
3. Click **New bucket**
4. Name it: `images`
5. Make it **Public**
6. Click **Save**

### Step 2: Set Up Policies (Optional)
For public read access:
```sql
-- Allow public to read images
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'images' );

-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'images' AND auth.role() = 'authenticated' );

-- Allow authenticated users to delete their uploads
CREATE POLICY "Users can delete own uploads"
ON storage.objects FOR DELETE
USING ( bucket_id = 'images' AND auth.role() = 'authenticated' );
```

Or allow anonymous uploads (for testing):
```sql
CREATE POLICY "Anyone can upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'images' );
```

## 💻 Usage Examples

### Example 1: Add Store with Image Upload
```dart
final StoreService storeService = StoreService();
final ImageService imageService = ImageService();

// Pick image
final XFile? image = await imageService.pickImageFromGallery();
if (image == null) return;

// Create store
final store = StoreModel(
  id: '',
  name: 'متجر الخضار',
  description: 'خضروات طازجة',
  imageUrl: '', // Will be set after upload
  category: 'خضروات',
  rating: 4.5,
  totalReviews: 100,
  isOpen: true,
  address: 'الرياض',
  phone: '+966501234567',
  createdAt: DateTime.now(),
);

// Upload image and create store
final String? storeId = await storeService.addStoreWithImage(
  store: store,
  imageFile: image,
);

print('Store created with ID: $storeId');
```

### Example 2: One-Click Upload
```dart
final String? storeId = await storeService.pickImageAndAddStore(
  store: storeModel,
  source: ImageSource.gallery, // or ImageSource.camera
);
```

### Example 3: Update Store Image
```dart
final XFile? newImage = await imageService.pickImageFromGallery();
if (newImage != null) {
  await storeService.updateStoreWithImage(
    storeId: 'store-id-123',
    imageFile: newImage,
    oldImageUrl: 'https://old-image-url.com/image.jpg',
  );
}
```

### Example 4: Delete Store with Image
```dart
await storeService.deleteStoreWithImage('store-id-123');
// This deletes both the Firestore document AND the Supabase image
```

## 📱 Add Store Page

Use the `AddStorePage` widget:

```dart
// In your navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AddStorePage(),
  ),
);
```

Or add to `main.dart` routes:
```dart
routes: {
  '/add-store': (context) => const AddStorePage(),
}
```

## 🔄 Data Flow

### Adding a Store with Image:
1. User picks image (gallery/camera)
2. Image uploaded to Supabase Storage bucket `images/stores/`
3. Supabase returns public URL
4. Store document created in Firestore with image URL
5. UI displays store with Supabase-hosted image

### Displaying Images:
- All images are served from Supabase CDN
- URLs are public and cached
- Example: `https://cpihytlerednyhqjkxne.supabase.co/storage/v1/object/public/images/stores/img_1234567890.jpg`

## 🎨 Image Storage Structure

```
images/                          # Bucket
  └── stores/                    # Folder
      ├── img_1699876543210.jpg
      ├── img_1699876544321.png
      └── img_1699876545432.jpg
```

## 🛡️ Security Best Practices

1. **Never commit `.env` file** (already in `.gitignore`)
2. **Use anon key for client-side** (already configured)
3. **Use service role key only for admin operations** (stored in `.env`)
4. **Set up RLS policies** in Supabase for production
5. **Limit file sizes** in image picker (already set to 1920x1080, 85% quality)

## 🚀 Testing

1. Run the app: `flutter run -d chrome`
2. Navigate to Add Store page
3. Click image placeholder to pick image
4. Fill in store details
5. Submit - image uploads to Supabase, store saves to Firestore
6. Check Supabase Storage dashboard to see uploaded images
7. Check Firestore to see store document with Supabase image URL

## 📊 Monitoring

### Supabase Dashboard
- Storage usage: https://cpihytlerednyhqjkxne.supabase.co/project/_/storage/usage
- View all images: https://cpihytlerednyhqjkxne.supabase.co/project/_/storage/buckets/images

### Firebase Console
- Firestore collections with image URLs
- All store documents reference Supabase-hosted images

## 🔧 Troubleshooting

### Image Upload Fails
1. Check Supabase bucket exists and is public
2. Verify `.env` credentials are correct
3. Check console for error messages
4. Ensure image picker has permissions (camera/gallery)

### Image Not Displaying
1. Verify bucket is public
2. Check image URL in Firestore document
3. Test URL directly in browser
4. Check CORS settings in Supabase

### Can't Create Bucket
- Bucket might already exist
- Use `createBucket()` method or create manually in dashboard

## 📖 Documentation

- [Supabase Storage Docs](https://supabase.com/docs/guides/storage)
- [Flutter Image Picker](https://pub.dev/packages/image_picker)
- [Supabase Flutter](https://supabase.com/docs/reference/dart)
