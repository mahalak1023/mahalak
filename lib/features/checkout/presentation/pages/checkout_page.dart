import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';
import 'package:myapp/core/widgets/app_text_field.dart';
import 'package:myapp/Services/cart_service.dart';
import 'package:myapp/Services/order_service.dart';
import 'package:myapp/features/orders/data/models/order_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _landmarkController = TextEditingController();

  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  bool _isProcessing = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Get cart items
      final cartSnapshot = await _cartService.getCartStream().first;

      if (cartSnapshot.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('السلة فارغة')));
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Convert cart items to order items
      final orderItems = cartSnapshot.map((cartItem) {
        return OrderItem(
          productId: cartItem.productId,
          productName: cartItem.name,
          productImage: cartItem.imageUrl,
          price: cartItem.price,
          quantity: cartItem.quantity,
          total: cartItem.total,
        );
      }).toList();

      // Calculate totals
      final subtotal = cartSnapshot.fold<double>(
        0.0,
        (sum, item) => sum + item.total,
      );
      const deliveryFee = 20.0; // Fixed delivery fee

      // Create delivery address
      final address = DeliveryAddress(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        building: _buildingController.text.trim(),
        floor: _floorController.text.trim().isNotEmpty
            ? _floorController.text.trim()
            : null,
        apartment: _apartmentController.text.trim().isNotEmpty
            ? _apartmentController.text.trim()
            : null,
        landmark: _landmarkController.text.trim().isNotEmpty
            ? _landmarkController.text.trim()
            : null,
      );

      // Create order
      final orderId = await _orderService.createOrder(
        items: orderItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        address: address,
        storeId: 'default_store', // TODO: Use actual store ID from cart
        storeName: 'المتجر الافتراضي', // TODO: Use actual store name
      );

      // Clear cart after successful order
      await _cartService.clearCart();

      if (mounted) {
        // Navigate to order details
        Navigator.pushReplacementNamed(
          context,
          '/order-details',
          arguments: orderId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل إنشاء الطلب: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'الدفع'),
        body: StreamBuilder(
          stream: _cartService.getCartStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cartItems = snapshot.data ?? [];
            if (cartItems.isEmpty) {
              return const Center(
                child: Text('السلة فارغة. أضف منتجات للمتابعة.'),
              );
            }

            final subtotal = cartItems.fold<double>(
              0.0,
              (sum, item) => sum + item.total,
            );
            const deliveryFee = 20.0;
            final total = subtotal + deliveryFee;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Text(
                      'ملخص الطلب',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('عدد المنتجات: ${cartItems.length}'),
                                Text('${subtotal.toStringAsFixed(2)} جنيه'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('رسوم التوصيل'),
                                Text('20.00 جنيه'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الإجمالي',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  '${total.toStringAsFixed(2)} جنيه',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Delivery Address
                    Text(
                      'عنوان التوصيل',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'الشارع *',
                      controller: _streetController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الشارع مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'المدينة *',
                      controller: _cityController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'المدينة مطلوبة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'رقم المبنى *',
                      controller: _buildingController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'رقم المبنى مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'الطابق (اختياري)',
                            controller: _floorController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'الشقة (اختياري)',
                            controller: _apartmentController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'علامة مميزة (اختياري)',
                      controller: _landmarkController,
                    ),
                    const SizedBox(height: 32),

                    // Payment Method (Cash on Delivery only for now)
                    Text(
                      'طريقة الدفع',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.money),
                        title: const Text('الدفع عند الاستلام'),
                        trailing: Radio(
                          value: true,
                          groupValue: true,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppPrimaryButton(
            text: _isProcessing ? 'جاري إنشاء الطلب...' : 'تأكيد الطلب',
            onPressed: _isProcessing ? null : _createOrder,
          ),
        ),
      ),
    );
  }
}
