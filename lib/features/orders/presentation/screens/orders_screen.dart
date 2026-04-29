import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/data/models/order_with_client.dart';
import 'package:talabati/features/orders/presentation/order_ui_helpers.dart';
import 'package:talabati/features/orders/presentation/providers/orders_provider.dart';
import 'package:talabati/features/orders/presentation/screens/add_edit_order_screen.dart';
import 'package:talabati/features/orders/presentation/screens/order_detail_placeholder_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersProvider);
    final orders = state.filteredOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(116),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: ref.read(ordersProvider.notifier).searchOrders,
                  decoration: InputDecoration(
                    hintText: 'Search by client or tracking number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: state.statusFilter == null,
                        onSelected: (_) => ref
                            .read(ordersProvider.notifier)
                            .filterByStatus(null),
                      ),
                    ),
                    for (final status in OrderStatus.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(shortOrderStatusLabel(status)),
                          selected: state.statusFilter == status,
                          onSelected: (_) => ref
                              .read(ordersProvider.notifier)
                              .filterByStatus(status),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _OrderTile(entry: orders[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditOrderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OrderTile extends ConsumerWidget {
  final OrderWithClient entry;

  const _OrderTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = entry.order;
    final currencyFormat = NumberFormat.currency(symbol: 'DA');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final showUnconfirmed =
        !order.isConfirmedByPhone &&
        (order.status == OrderStatus.newOrder ||
            order.status == OrderStatus.called);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.clientName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            OrderStatusChip(status: order.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.order.wilaya),
              Text(
                '${currencyFormat.format(order.totalAmount)} total '
                '(${currencyFormat.format(order.deliveryFee)} delivery)',
              ),
              Text(dateFormat.format(order.createdAt)),
              if (showUnconfirmed)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚠ Unconfirmed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: entry.clientPhone.isEmpty
              ? null
              : () => _launchPhone(context, entry.clientPhone),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailPlaceholderScreen(orderId: order.id),
            ),
          );
        },
        onLongPress: () => _confirmDelete(context, ref),
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Delete order for ${entry.clientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(ordersProvider.notifier).deleteOrder(entry.order.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
