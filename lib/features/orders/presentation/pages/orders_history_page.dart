
import 'package:flutter/material.dart';

class OrdersHistoryPage extends StatelessWidget {
  const OrdersHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
        ),
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text('طلب رقم #${12345 + index}'),
                subtitle: const Text('تم التسليم'),
                trailing: const Text('300 ر.س'),
                onTap: () {
                  Navigator.pushNamed(context, '/order-details');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
