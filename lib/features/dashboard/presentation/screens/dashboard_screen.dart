import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:talabati/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:talabati/features/orders/presentation/order_ui_helpers.dart';
import 'package:talabati/features/orders/presentation/screens/order_detail_placeholder_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'DA');

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: ref.read(dashboardProvider.notifier).loadDashboard,
        child: state.isLoading && state.totalOrders == 0
            ? const Center(child: CircularProgressIndicator())
            : state.totalOrders == 0
            ? _buildEmptyState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryGrid(state),
                    const SizedBox(height: 16),
                    _buildRevenueCard(state, currencyFormat),
                    const SizedBox(height: 16),
                    _buildReturnsCard(state),
                    const SizedBox(height: 16),
                    _buildRecentOrdersCard(state.recentOrders, currencyFormat),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 88, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No orders yet. Start by adding your first order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryGrid(DashboardState state) {
    final cards = [
      _SummaryItem('Today\'s Orders', state.todaysOrders, Icons.today),
      _SummaryItem(
        'Pending Confirmation',
        state.pendingConfirmation,
        Icons.phone_in_talk,
      ),
      _SummaryItem('With Courier', state.withCourier, Icons.local_shipping),
      _SummaryItem(
        'Awaiting Collection',
        state.deliveredAwaitingCollection,
        Icons.payments,
      ),
    ];

    return SizedBox(
      height: 300,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 144,
        ),
        itemBuilder: (context, index) {
          final item = cards[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCard(DashboardState state, NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _valueRow(
              'This month\'s revenue',
              currencyFormat.format(state.monthlyRevenue),
            ),
            _valueRow(
              'This month\'s profit',
              currencyFormat.format(state.monthlyProfit),
            ),
            _valueRow(
              'Pending revenue',
              currencyFormat.format(state.pendingRevenue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnsCard(DashboardState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Returns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _valueRow('Returns this month', state.returnsThisMonth.toString()),
            if (state.topReturningClients.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Top returning clients',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (
                var index = 0;
                index < state.topReturningClients.length;
                index++
              )
                _returningClientRow(index, state.topReturningClients[index]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersCard(
    List<RecentOrderStat> orders,
    NumberFormat currencyFormat,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final order in orders)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailPlaceholderScreen(orderId: order.orderId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.wilaya} - ${dateFormat.format(order.createdAt)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(order.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          OrderStatusChip(status: order.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _valueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _returningClientRow(int index, TopReturningClientStat client) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(client.name)),
          Text(
            '${client.returnCount} returns',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final int value;
  final IconData icon;

  const _SummaryItem(this.label, this.value, this.icon);
}
