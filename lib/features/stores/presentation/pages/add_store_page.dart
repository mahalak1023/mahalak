import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/theme/app_text_styles.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';
import 'package:myapp/Services/store_service.dart';
import 'package:myapp/Services/image_service.dart';
import 'package:myapp/features/stores/data/models/store_model.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({super.key});

  @override
  State<AddStorePage> createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final StoreService _storeService = StoreService();
  final ImageService _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;
  bool _isOpen = true;
  double _rating = 4.0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? image;
      if (source == ImageSource.gallery) {
        image = await _imageService.pickImageFromGallery();
      } else {
        image = await _imageService.pickImageFromCamera();
      }

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitStore() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة للمتجر')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final store = StoreModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: '', // Will be set after upload
        category: _categoryController.text.trim(),
        rating: _rating,
        totalReviews: 0,
        isOpen: _isOpen,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Add store with image upload to Supabase
      final String? storeId = await _storeService.addStoreWithImage(
        store: store,
        imageFile: _selectedImage!,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (storeId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة المتجر بنجاح'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إضافة المتجر'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'إضافة متجر جديد'),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Image picker
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _selectedImage!.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text('اضغط لاختيار صورة'),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('اضغط لاختيار صورة المتجر'),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المتجر',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال اسم المتجر' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال الوصف' : null,
              ),
              const SizedBox(height: 16),

              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال الفئة' : null,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'الرجاء إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 16),

              // Rating
              Row(
                children: [
                  Text(
                    'التقييم: ${_rating.toStringAsFixed(1)}',
                    style: AppTextStyles.body,
                  ),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.amber),
                ],
              ),

              // Is Open
              SwitchListTile(
                title: const Text('المتجر مفتوح'),
                value: _isOpen,
                onChanged: (value) => setState(() => _isOpen = value),
              ),
              const SizedBox(height: 24),

              // Submit button
              AppPrimaryButton(
                text: _isLoading ? 'جاري الإضافة...' : 'إضافة المتجر',
                onPressed: _isLoading ? null : _submitStore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
