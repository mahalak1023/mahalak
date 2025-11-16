
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 100)),
              ),
              const SizedBox(height: 20),
              const Text('اسم المنتج', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('99.99 ر.س', style: TextStyle(fontSize: 20, color: Colors.green)),
              const SizedBox(height: 10),
              const Text('وصف تفصيلي للمنتج هنا. هذا النص هو مثال لوصف المنتج ويمكن أن يكون أطول من ذلك.'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.pushNamed(context, '/cart');
                  },
                  child: const Text('إضافة إلى السلة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
