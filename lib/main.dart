import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Theme
import 'core/theme/app_theme.dart';

// Services
import 'Services/auth_service.dart';

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

void main() {
  runApp(const MahallakApp());
}

class MahallakApp extends StatefulWidget {
  const MahallakApp({super.key});

  @override
  State<MahallakApp> createState() => _MahallakAppState();
}

class _MahallakAppState extends State<MahallakApp> {
  final AuthService _authService = AuthService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _hasCheckedRedirect = false;

  @override
  void initState() {
    super.initState();
    // Handle redirect result for web OAuth (Google/Apple sign-in)
    if (kIsWeb) {
      _handleRedirectResult();
    }
  }

  Future<void> _handleRedirectResult() async {
    try {
      print('Checking for redirect result...');
      final result = await _authService.getRedirectResult();

      if (result != null && result.user != null) {
        // User successfully signed in via redirect
        print('✅ SUCCESS: Sign-in successful!');
        print('User: ${result.user?.email}');
        print('Display Name: ${result.user?.displayName}');
        print('UID: ${result.user?.uid}');

        _hasCheckedRedirect = true;
        // Wait a bit for the StreamBuilder to rebuild, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } else {
        print('ℹ️ INFO: No redirect result found (normal page load)');
        _hasCheckedRedirect = true;
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: Failed to handle redirect result');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      _hasCheckedRedirect = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro size as reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Check if we have auth state
            final isAuthenticated = snapshot.hasData && snapshot.data != null;

            return MaterialApp(
              navigatorKey: _navigatorKey,
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
          initialRoute: isAuthenticated ? '/home' : '/',

          routes: {
            // Auth
            '/': (context) => const AuthEntryPage(),
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
      },
    );
  }
}
