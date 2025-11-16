import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_empty_state.dart';
import 'package:myapp/core/widgets/app_primary_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCartEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'السلة'),
        body: _isCartEmpty
            ? AppEmptyState(
                title: 'سلتك فارغة!',
                description: 'أضف بعض المنتجات إلى سلتك لبدء التسوق.',
                lottieAssetPath: 'assets/lottie/empty-cart.json',
                onButtonPressed: () {
                  setState(() {
                    _isCartEmpty = false;
                  });
                },
                buttonText: 'ابدأ التسوق',
              )
            : const CartView(),
        bottomNavigationBar: _isCartEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppPrimaryButton(
                  text: 'الانتقال إلى الدفع',
                  onPressed: () {
                    // TODO: Navigate to checkout page
                  },
                ),
              ),
      ),
    );
  }
}

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3, // Example item count
      itemBuilder: (context, index) => const CartItemCard(),
    );
  }
}

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(
              'https://picsum.photos/100/100?random=$hashCode',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اسم المنتج', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('50.00 ر.س', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                const Text('1', style: TextStyle(fontSize: 16)),
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
