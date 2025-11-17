import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/Services/order_service.dart';
import 'package:myapp/features/orders/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = args is String
        ? args
        : (args is Map ? args['orderId'] : null);
    if (orderId == null) {
      return const Scaffold(
        appBar: AppAppBar(title: 'تفاصيل الطلب'),
        body: Center(child: Text('لم يتم تمرير رقم الطلب')),
      );
    }

    final orderService = OrderService();

    return Scaffold(
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
                // Order Status Card
                Card(
                  color: _statusColor(order.status).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          _statusIcon(order.status),
                          color: _statusColor(order.status),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.status.arabicName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'رقم الطلب: ${order.orderId}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Date
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('تاريخ الطلب'),
                    subtitle: Text(_formatDate(order.createdAt)),
                  ),
                ),
                const SizedBox(height: 16),

                // Store Info (if available)
                if (order.storeName != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text('المتجر'),
                      subtitle: Text(order.storeName!),
                    ),
                  ),
                if (order.storeName != null) const SizedBox(height: 16),

                _buildSectionTitle(context, 'المنتجات'),
                const SizedBox(height: 8),
                ...order.items.map(
                  (it) => OrderItemTile(
                    name: it.productName,
                    image: it.productImage ?? 'https://picsum.photos/200',
                    price: it.price,
                    quantity: it.quantity,
                    total: it.total,
                  ),
                ),
                const SizedBox(height: 8),

                // Totals Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTotalRow(
                          'المجموع الفرعي',
                          '${order.subtotal.toStringAsFixed(2)} جنيه',
                        ),
                        const Divider(),
                        _buildTotalRow(
                          'رسوم التوصيل',
                          '${order.deliveryFee.toStringAsFixed(2)} جنيه',
                        ),
                        const Divider(),
                        _buildTotalRow(
                          'الإجمالي',
                          '${order.total.toStringAsFixed(2)} جنيه',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle(context, 'عنوان التوصيل'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAddressRow(
                          Icons.location_city,
                          'المدينة',
                          order.address.city,
                        ),
                        const SizedBox(height: 8),
                        _buildAddressRow(
                          Icons.add_road,
                          'الشارع',
                          order.address.street,
                        ),
                        const SizedBox(height: 8),
                        _buildAddressRow(
                          Icons.home,
                          'رقم المبنى',
                          order.address.building ?? '',
                        ),
                        if (order.address.floor != null) ...[
                          const SizedBox(height: 8),
                          _buildAddressRow(
                            Icons.stairs,
                            'الطابق',
                            order.address.floor!,
                          ),
                        ],
                        if (order.address.apartment != null) ...[
                          const SizedBox(height: 8),
                          _buildAddressRow(
                            Icons.door_front_door,
                            'الشقة',
                            order.address.apartment!,
                          ),
                        ],
                        if (order.address.landmark != null) ...[
                          const SizedBox(height: 8),
                          _buildAddressRow(
                            Icons.location_on,
                            'علامة مميزة',
                            order.address.landmark!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'ملاحظات'),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(order.notes!),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy, h:mm a', 'ar');
    return formatter.format(date);
  }

  Widget _buildAddressRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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

IconData _statusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.schedule;
    case OrderStatus.confirmed:
      return Icons.check_circle_outline;
    case OrderStatus.preparing:
      return Icons.restaurant;
    case OrderStatus.readyForPickup:
      return Icons.shopping_bag;
    case OrderStatus.outForDelivery:
      return Icons.local_shipping;
    case OrderStatus.delivered:
      return Icons.check_circle;
    case OrderStatus.cancelled:
      return Icons.cancel;
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
    required this.image,
    required this.price,
    required this.quantity,
    required this.total,
  });

  final String name;
  final String image;
  final double price;
  final int quantity;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'السعر: ${price.toStringAsFixed(2)} جنيه',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الكمية: $quantity',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              '${total.toStringAsFixed(2)} جنيه',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
