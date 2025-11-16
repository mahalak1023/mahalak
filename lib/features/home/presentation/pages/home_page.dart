import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_bottom_nav_bar.dart';
import 'package:myapp/core/widgets/app_section_title.dart';
import 'package:myapp/core/widgets/app_text_field.dart';
import 'package:myapp/features/home/presentation/widgets/product_card.dart';
import 'package:myapp/features/home/presentation/widgets/store_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock data for demonstration
  final List<Map<String, dynamic>> stores = [
    {
      "name": "سوبر ماركت الأمانة",
      "category": "بقالة عامة",
      "delivery": "30-45 دقيقة",
      "rating": 4.5,
    },
    {
      "name": "مخبز وحلويات النجاح",
      "category": "مخبوزات",
      "delivery": "20-30 دقيقة",
      "rating": 4.8,
    },
    {
      "name": "ملحمة أبو أحمد",
      "category": "لحوم ودواجن",
      "delivery": "45-60 دقيقة",
      "rating": 4.2,
    },
  ];

  final List<Map<String, dynamic>> products = [
    {
      "name": "جبنة بيضاء بلدي - 1 كغ",
      "store": "سوبر ماركت الأمانة",
      "price": 75.0,
      "oldPrice": 90.0,
      "imageUrl": "https://picsum.photos/seed/cheese/400/400",
    },
    {
      "name": "خبز أسمر طازج - كيس",
      "store": "مخبز وحلويات النجاح",
      "price": 5.0,
      "oldPrice": null,
      "imageUrl": "https://picsum.photos/seed/bread/400/400",
    },
    {
      "name": "دجاج كامل طازج - 900غ",
      "store": "ملحمة أبو أحمد",
      "price": 28.0,
      "oldPrice": 32.0,
      "imageUrl": "https://picsum.photos/seed/chicken/400/400",
    },
    {
      "name": "زيت زيتون بكر - 500مل",
      "store": "سوبر ماركت الأمانة",
      "price": 45.0,
      "oldPrice": null,
      "imageUrl": "https://picsum.photos/seed/olive/400/400",
    },
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: "محلك", showBack: false),
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust padding for cards
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return StoreCard(
          storeName: store['name']!,
          category: store['category']!,
          deliveryTimeText: store['delivery']!,
          rating: store['rating']!,
          onTap: () => Navigator.pushNamed(context, '/products'),
        );
      },
    );
  }

  Widget _buildPopularProductsList() {
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
              productName: product['name']!,
              storeName: product['store']!,
              price: product['price']!,
              oldPrice: product['oldPrice']!,
              imageUrl: product['imageUrl']!,
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
  }
}
