import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_empty_state.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';
import 'package:myapp/Services/cart_service.dart';
import 'package:myapp/features/cart/data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCartEmpty = false;
  final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'السلة'),
        body: StreamBuilder<List<CartItemModel>>(
          stream: _cartService.getCartStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return AppEmptyState(
                title: 'سلتك فارغة!',
                description: 'أضف بعض المنتجات إلى سلتك لبدء التسوق.',
                lottieAssetPath: 'assets/lottie/empty-cart.json',
                onButtonPressed: () {},
                buttonText: 'ابدأ التسوق',
              );
            }

            return CartView(items: items);
          },
        ),
        bottomNavigationBar: _isCartEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<double>(
                  future: _cartService.getCartTotal(),
                  builder: (context, snap) {
                    final total = snap.data ?? 0.0;
                    return AppPrimaryButton(
                      text:
                          'الانتقال إلى الدفع - ${total.toStringAsFixed(2)} ر.س',
                      onPressed: () {
                        // TODO: Navigate to checkout page
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class CartView extends StatelessWidget {
  const CartView({super.key, required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemCard(item: item);
      },
    );
  }
}

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (item.imageUrl != null)
              Image.network(
                item.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} ر.س',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () async {
                    final newQty = (item.quantity - 1).clamp(1, 999);
                    await cartService.updateQuantity(item.id, newQty);
                  },
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await cartService.updateQuantity(
                      item.id,
                      item.quantity + 1,
                    );
                  },
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                await cartService.removeItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
