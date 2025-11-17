import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_empty_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'طلباتي'),
        body: const OrdersListView(),
      ),
    );
  }
}

class OrdersListView extends StatelessWidget {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3, // Example order count
      itemBuilder: (context, index) => OrderListItem(
        orderNumber: '#12345${index + 1}',
        date: '2023-10-27',
        status: 'تم التوصيل',
        total: 150.00,
        onTap: () => Navigator.pushNamed(context, '/orders/details'),
      ),
    );
  }
}

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    super.key,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.total,
    this.onTap,
  });

  final String orderNumber;
  final String date;
  final String status;
  final double total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text('طلب رقم $orderNumber'),
        subtitle: Text('بتاريخ: $date\nالحالة: $status'),
        trailing: Text(
          '$total ر.س',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
