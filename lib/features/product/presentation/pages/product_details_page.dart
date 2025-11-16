
import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/features/product/presentation/widgets/add_to_cart_bar.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/400/600'), // Placeholder
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name & Store
            Text(
              'Modern Wall Clock',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'From Furniture Store',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Rating
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                Icon(Icons.star, color: Colors.amber, size: 20),
                Icon(Icons.star, color: Colors.amber, size: 20),
                Icon(Icons.star, color: Colors.amber, size: 20),
                Icon(Icons.star_half, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('4.5 (120 reviews)', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),

            // Price
            Row(
              children: [
                const Text(
                  '\$99.99',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '\$129.99',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Product Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This modern wall clock is a perfect addition to any room. It features a silent quartz movement and a sleek, minimalist design. Made from high-quality materials, it is built to last and will complement any decor style. Easy to hang and requires one AA battery (not included).',
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
            ),
             const SizedBox(height: 100), // To avoid overlap with bottom bar
          ],
        ),
      ),
      bottomNavigationBar: AddToCartBar(
        productPrice: 99.99,
        onAddToCart: () {
          // TODO: Implement add to cart logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to cart!')),
          );
        },
      ),
    );
  }
}
