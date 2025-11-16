import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/services/firestore_service.dart';
import 'firebase_options.dart';

// Theme
import 'core/theme/app_theme.dart';

// Auth
import 'features/auth/presentation/pages/auth_entry_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';

// Home + Stores + Products list
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/store_list_page.dart';
import 'features/home/presentation/pages/product_list_page.dart';

// Product details
import 'features/product/presentation/pages/product_details_page.dart';

// Cart
import 'features/cart/presentation/pages/cart_page.dart';

// Address
import 'features/address/presentation/pages/address_picker_page.dart';
import 'features/address/presentation/pages/add_address_page.dart';

// Checkout + Order status
import 'features/checkout/presentation/pages/checkout_page.dart';
import 'features/checkout/presentation/pages/order_status_page.dart';

// Orders
import 'features/orders/presentation/pages/orders_history_page.dart';
import 'features/orders/presentation/pages/order_details_page.dart';

// Support
import 'features/support/presentation/pages/help_center_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirestoreService().addSampleData(); // Add sample data
  runApp(const MahallakApp());
}

class MahallakApp extends StatelessWidget {
  const MahallakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro size as reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'محلك',
          debugShowCheckedModeBanner: false,

          // نظام التصميم الرسمي
          theme: AppTheme.lightTheme,

          // اتجاه RTL للتطبيق كله
          builder: (context, widget) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: widget ?? const SizedBox.shrink(),
            );
          },

          // أول شاشة
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                return const HomePage();
              }
              return const AuthEntryPage();
            },
          ),

          routes: {
            // Auth
            '/otp': (context) => const OtpPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),

            // Home & Stores
            '/home': (context) => const HomePage(),
            '/stores': (context) => const StoreListPage(),
            '/products': (context) => const ProductListPage(),

            // Product
            '/product-details': (context) => const ProductDetailsPage(),

            // Cart
            '/cart': (context) => const CartPage(),

            // Address
            '/address-picker': (context) => const AddressPickerPage(),
            '/add-address': (context) => const AddAddressPage(),

            // Checkout + order status
            '/checkout': (context) => const CheckoutPage(),
            '/order-status': (context) => const OrderStatusPage(),

            // Orders
            '/orders': (context) => const OrdersHistoryPage(),
            '/order-details': (context) => const OrderDetailsPage(),

            // Support
            '/help-center': (context) => const HelpCenterPage(),
          },
        );
      },
    );
  }
}
