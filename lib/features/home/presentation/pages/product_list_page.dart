import 'package:flutter/material.dart';
import 'package:myapp/Services/cart_service.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('منتجات المتجر')),
        body: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.8,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final cartService = CartService();
            final productId = 'prod_${index + 1}';
            final productName = 'منتج رقم ${index + 1}';
            final productPrice = 10.0 + index; // example price
            final productImage = 'https://picsum.photos/seed/$index/400/400';

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/product-details');
              },
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey[300],
                        child: Image.network(
                          productImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(productName)),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () async {
                              try {
                                await cartService.addOrIncrementItem(
                                  productId: productId,
                                  name: productName,
                                  imageUrl: productImage,
                                  price: productPrice,
                                  quantity: 1,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم إضافة المنتج إلى السلة',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('خطأ أثناء الإضافة: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
