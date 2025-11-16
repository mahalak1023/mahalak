
import 'package:flutter/material.dart';

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حالة الطلب'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('تم استلام الطلب'),
              ),
              const ListTile(
                leading: Icon(Icons.hourglass_top, color: Colors.orange),
                title: Text('جاري التحضير'),
              ),
              const ListTile(
                leading: Icon(Icons.local_shipping, color: Colors.blue),
                title: Text('في الطريق'),
              ),
              const ListTile(
                leading: Icon(Icons.delivery_dining, color: Colors.grey),
                title: Text('تم التسليم'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/orders');
                },
                child: const Text('عرض كل طلباتي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
