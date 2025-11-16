import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/services/firestore_service.dart';
import 'package:myapp/core/widgets/app_bottom_nav_bar.dart';
import 'package:myapp/core/widgets/app_section_title.dart';
import 'package:myapp/core/widgets/app_text_field.dart';
import 'package:myapp/features/home/data/models/store_model.dart';
import 'package:myapp/features/home/presentation/widgets/store_card.dart';
import 'package:myapp/features/product/data/models/product_model.dart';
import 'package:myapp/features/home/presentation/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<StoreModel>> _storesFuture;
  late Future<List<ProductModel>> _productsFuture;

  final List<String> categories = [
    "الكل",
    "بقالة",
    "خضار وفاكهة",
    "مخبوزات",
    "لحوم ودواجن",
    "ألبان وأجبان",
  ];

  int _currentIndex = 0; // For bottom nav bar

  @override
  void initState() {
    super.initState();
    _storesFuture = _firestoreService.getStores();
    _productsFuture = _firestoreService.getProducts();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محلك'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search + Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "أهلاً بك 👋",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, size: 28),
                    onPressed: () {
                      // TODO: Navigate to notifications page
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AppTextField(
                hint: "ابحث عن منتج أو متجر...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Banner Carousel
            _buildBannerCarousel(),

            const SizedBox(height: 24),

            // 3. Categories
            _buildCategoriesList(),

            const SizedBox(height: 24),

            // 4. Nearby Stores Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppSectionTitle(
                title: "متاجر قريبة منك",
                actionText: "عرض الكل",
                onActionTap: () => Navigator.pushNamed(context, '/stores'),
              ),
            ),
            const SizedBox(height: 8),
            _buildNearbyStoresList(),

            const SizedBox(height: 24),

            // 5. Popular Products Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AppSectionTitle(title: "الأكثر مبيعًا"),
            ),
            const SizedBox(height: 8),
            _buildPopularProductsList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Handle navigation
          switch (index) {
            case 0: // Home - do nothing
              break;
            case 1: // Orders
              Navigator.pushNamed(context, '/orders');
              break;
            case 2: // Cart
              Navigator.pushNamed(context, '/cart');
              break;
            case 3: // Profile
              // Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: 2, // 2 Banners
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: index == 0
                    ? [Colors.blue.shade200, Colors.blue.shade500]
                    : [Colors.green.shade200, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 0 ? "عروض خاصة اليوم" : "منتجات طازجة",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0
                        ? "خصومات تصل إلى 30% على البقالة"
                        : "اكتشف أفضل الخضروات والفواكه",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildCategoriesList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: index == 0, // Mock selection
              onSelected: (selected) {
                // In a real app, filter products/stores
                Navigator.pushNamed(context, '/stores');
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyStoresList() {
    return FutureBuilder<List<StoreModel>>(
      future: _storesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final stores = snapshot.data ?? [];
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust padding for cards
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return StoreCard(
              storeName: store.name,
              category: store.category,
              deliveryTimeText: store.deliveryTime,
              rating: store.rating,
              onTap: () => Navigator.pushNamed(context, '/products'),
            );
          },
        );
      },
    );
  }

  Widget _buildPopularProductsList() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final products = snapshot.data ?? [];
        return SizedBox(
          height: 280, // Adjust height based on ProductCard size
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 180, // Set a fixed width for horizontal cards
                child: ProductCard(
                  productName: product.name,
                  storeName: product.store,
                  price: product.price,
                  oldPrice: product.oldPrice,
                  imageUrl: product.imageUrl,
                  onTap: () => Navigator.pushNamed(context, '/product-details'),
                  onAddToCart: () {
                    // TODO: Add to cart logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت الإضافة إلى السلة')),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
