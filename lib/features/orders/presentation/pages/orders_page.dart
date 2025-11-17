import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/app_app_bar.dart';
import 'package:myapp/core/widgets/app_empty_state.dart';
import 'package:myapp/Services/order_service.dart';
import 'package:myapp/features/orders/data/models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppAppBar(title: 'طلباتي'),
        body: const OrdersListView(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Create sample orders for testing
            final orderService = OrderService();
            try {
              await orderService.createSampleOrders();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إنشاء طلبات تجريبية')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
              }
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('إنشاء طلبات تجريبية'),
        ),
    );
  }
}

class OrdersListView extends StatelessWidget {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return StreamBuilder<List<OrderModel>>(
      stream: orderService.getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const AppEmptyState(
            title: 'لا توجد طلبات',
            description: 'لم تقم بإنشاء أي طلبات بعد',
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderListItem(
              order: order,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/order-details',
                  arguments: order.orderId,
                );
              },
            );
          },
        );
      },
    );
  }
}

class OrderListItem extends StatelessWidget {
  const OrderListItem({super.key, required this.order, this.onTap});

  final OrderModel order;
  final VoidCallback? onTap;

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.outForDelivery:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.orderId.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.arabicName,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Store name (if available)
              if (order.storeName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        order.storeName!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              // Date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(order.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count and total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} منتج',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
