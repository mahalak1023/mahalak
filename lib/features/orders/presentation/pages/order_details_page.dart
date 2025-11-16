
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الطلب'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('طلب رقم #12345', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('الحالة: تم التسليم'),
              const SizedBox(height: 20),
              const Text('المنتجات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const ListTile(
                title: Text('منتج 1'),
                trailing: Text('100 ر.س'),
              ),
              const ListTile(
                title: Text('منتج 2'),
                trailing: Text('200 ر.س'),
              ),
              const Divider(),
              const ListTile(
                title: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('300 ر.س', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
               ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/help-center');
                },
                child: const Text('المساعدة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
