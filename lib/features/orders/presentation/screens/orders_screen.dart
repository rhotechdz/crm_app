import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/core/theme/app_colors.dart';
import 'package:talabati/features/orders/data/models/delivery_company.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrdersHeader(totalOrders: state.orders.length, ref: ref),
          const SizedBox(height: 26),
          _FilterChips(state: state, ref: ref),
          const SizedBox(height: 8),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: 92 + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _OrderCard(entry: orders[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditOrderScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  final int totalOrders;
  final WidgetRef ref;

  const _OrdersHeader({required this.totalOrders, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.navyDark,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 46),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalOrders orders total',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: -24,
          child: _FloatingSearchBar(
            hint: 'Search by client or tracking number...',
            onChanged: ref.read(ordersProvider.notifier).searchOrders,
          ),
        ),
      ],
    );
  }
}

class _FloatingSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _FloatingSearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final OrdersState state;
  final WidgetRef ref;

  const _FilterChips({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _filterChip(
            'All',
            state.statusFilter == null,
            () => ref.read(ordersProvider.notifier).filterByStatus(null),
          ),
          for (final status in OrderStatus.values)
            _filterChip(
              shortOrderStatusLabel(status),
              state.statusFilter == status,
              () => ref.read(ordersProvider.notifier).filterByStatus(status),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.accent,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: selected ? AppColors.accent : AppColors.divider,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderWithClient entry;

  const _OrderCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = entry.order;
    final currencyFormat = NumberFormat.currency(symbol: 'DA');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.accent.withOpacity(0.08),
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OrderStatusChip(status: order.status),
                    const Spacer(),
                    Text(
                      dateFormat.format(order.createdAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  entry.clientName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.wilaya} • ${order.deliveryCompany.label}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Divider(height: 22, color: AppColors.divider),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currencyFormat.format(order.totalAmount),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: entry.clientPhone.isEmpty
                          ? null
                          : () => _launchPhone(context, entry.clientPhone),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: AppColors.accent,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
