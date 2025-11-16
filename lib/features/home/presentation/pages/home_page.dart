
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محلك'),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: const Text('بانر عروض'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text('الأقسام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) => Container(
                  width: 100,
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.grey[300],
                  child: Center(child: Text('قسم ${index + 1}')),
                )),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text('متاجر قريبة منك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text('متجر 1'),
              onTap: () => Navigator.pushNamed(context, '/stores'),
            ),
            ListTile(
              title: const Text('متجر 2'),
              onTap: () => Navigator.pushNamed(context, '/stores'),
            ),
            ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/orders'), child: Text("الطلبات"))
          ],
        ),
      ),
    );
  }
}
