import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'تفاصيل الطلب'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'معلومات الطلب'),
              _buildInfoRow('رقم الطلب:', '#123456'),
              _buildInfoRow('تاريخ الطلب:', '2023-10-27'),
              _buildInfoRow('الحالة:', 'تم التوصيل', color: Colors.green),
              const Divider(height: 32),
              _buildSectionTitle(context, 'ملخص الطلب'),
              const OrderItemTile(name: 'منتج 1', price: '50.00 ر.س', quantity: 2),
              const OrderItemTile(name: 'منتج 2', price: '50.00 ر.س', quantity: 1),
              const Divider(),
              _buildTotalRow('المجموع الفرعي', '150.00 ر.س'),
              _buildTotalRow('رسوم التوصيل', '15.00 ر.س'),
              _buildTotalRow('الإجمالي', '165.00 ر.س', isTotal: true),
              const Divider(height: 32),
              _buildSectionTitle(context, 'عنوان التوصيل'),
              const Text('الاسم الكامل\nشارع المثال، المدينة، الرمز البريدي'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String name;
  final String price;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.network(
        'https://picsum.photos/100/100?random=$hashCode',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(name),
      subtitle: Text('الكمية: $quantity'),
      trailing: Text(price),
    );
  }
}
