
import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إتمام الطلب'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ملخص الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 20),
              const Text('عنوان التوصيل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('الرياض, حي الملز, شارع الستين'),
              const SizedBox(height: 20),
              const Text('طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('الدفع عند الاستلام'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/order-status');
                  },
                  child: const Text('تأكيد الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
