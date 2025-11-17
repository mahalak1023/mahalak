import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/Services/order_service.dart';
import 'package:myapp/features/orders/data/models/order_model.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = args is String
        ? args
        : (args is Map ? args['orderId'] : null);
    if (orderId == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: const AppAppBar(title: 'تفاصيل الطلب'),
          body: const Center(child: Text('لم يتم تمرير رقم الطلب')),
        ),
      );
    }

    final orderService = OrderService();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppAppBar(title: 'تفاصيل الطلب'),
        body: StreamBuilder<OrderModel?>(
          stream: orderService.streamOrder(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final order = snapshot.data;
            if (order == null) {
              return const Center(child: Text('الطلب غير موجود'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'معلومات الطلب'),
                  _buildInfoRow('رقم الطلب:', order.orderId),
                  _buildInfoRow('تاريخ الطلب:', order.createdAt.toString()),
                  _buildInfoRow(
                    'الحالة:',
                    order.status.arabicName,
                    color: _statusColor(order.status),
                  ),
                  const Divider(height: 32),
                  _buildSectionTitle(context, 'ملخص الطلب'),
                  ...order.items.map(
                    (it) => OrderItemTile(
                      name: it.productName,
                      price: '${it.total.toStringAsFixed(2)} ر.س',
                      quantity: it.quantity,
                    ),
                  ),
                  const Divider(),
                  _buildTotalRow(
                    'المجموع الفرعي',
                    '${order.subtotal.toStringAsFixed(2)} ر.س',
                  ),
                  _buildTotalRow(
                    'رسوم التوصيل',
                    '${order.deliveryFee.toStringAsFixed(2)} ر.س',
                  ),
                  _buildTotalRow(
                    'الإجمالي',
                    '${order.total.toStringAsFixed(2)} ر.س',
                    isTotal: true,
                  ),
                  const Divider(height: 32),
                  _buildSectionTitle(context, 'عنوان التوصيل'),
                  Text('${order.address.street}\n${order.address.city}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return Colors.green;
    case OrderStatus.cancelled:
      return Colors.red;
    case OrderStatus.outForDelivery:
      return Colors.orange;
    default:
      return Colors.grey;
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
