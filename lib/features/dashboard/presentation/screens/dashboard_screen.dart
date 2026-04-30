import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/theme/talabati_theme.dart' hide OrderStatus;
import 'package:talabati/theme/talabati_theme.dart' as theme;
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/status_badge.dart';
import 'package:talabati/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:talabati/features/dashboard/data/repositories/dashboard_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);

    if (dashboard.isLoading) {
      return const Scaffold(
        appBar: TalabatiAppBar(title: 'Talabati'),
        body: Center(
          child: CircularProgressIndicator(color: TalabatiColors.primary),
        ),
      );
    }

    // Adapt state data to UI needs
    final totalRevenue = dashboard.monthlyRevenue + dashboard.pendingRevenue;
    const monthlyTarget = 3500000.0;
    final ratio = (dashboard.monthlyRevenue / monthlyTarget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: const TalabatiAppBar(title: 'Talabati'),
      body: SingleChildScrollView(
        padding: TalabatiSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TalabatiSpacing.sm),
            Text(
              'Sbah el khir, Admin',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: TalabatiSpacing.xs),
            Text(
              'Here is what\'s happening with Talabati today.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TalabatiSpacing.xl),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'TODAY\'S ORDERS',
                    value: dashboard.todaysOrders.toString(),
                    badgeLabel: null, // growth percent not available
                    badgeBg: TalabatiColors.successLight,
                    badgeText: TalabatiColors.success,
                  ),
                ),
                const SizedBox(width: TalabatiSpacing.base),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.phone_outlined,
                    label: 'PENDING CALLS',
                    value: dashboard.pendingConfirmation.toString(),
                    badgeLabel: dashboard.pendingConfirmation > 0 ? 'URGENT' : null,
                    badgeBg: TalabatiColors.dangerLight,
                    badgeText: TalabatiColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.base),
            
            // Total Revenue Card
            _buildTotalRevenueCard(context, totalRevenue),
            const SizedBox(height: TalabatiSpacing.base),
            
            // Revenue Highlight Card
            _buildRevenueHighlightCard(context, dashboard.monthlyRevenue, monthlyTarget, ratio),
            const SizedBox(height: TalabatiSpacing.xl),
            
            // Recent Orders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.sm),
            
            // Recent Orders List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboard.recentOrders.length > 5 ? 5 : dashboard.recentOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.sm),
              itemBuilder: (context, index) {
                final order = dashboard.recentOrders[index];
                return _buildRecentOrderListItem(context, order);
              },
            ),
            const SizedBox(height: 100), // Bottom spacing
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? badgeLabel,
    required Color badgeBg,
    required Color badgeText,
  }) {
    return Card(
      child: Padding(
        padding: TalabatiSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: TalabatiColors.primary, size: 24),
                if (badgeLabel != null)
                  StatusBadge(
                    label: badgeLabel,
                    backgroundColor: badgeBg,
                    textColor: badgeText,
                  )
                else
                  const SizedBox(height: 24),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.lg),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TalabatiColors.textSecondary,
                  ),
            ),
            const SizedBox(height: TalabatiSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard(BuildContext context, double totalRevenue) {
    final formattedValue = '${NumberFormat('#,###', 'en_US').format(totalRevenue)} DA';
    return Card(
      child: Padding(
        padding: TalabatiSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(TalabatiSpacing.md),
              decoration: BoxDecoration(
                color: TalabatiColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: TalabatiColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: TalabatiSpacing.base),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL REVENUE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TalabatiColors.textSecondary,
                      ),
                ),
                const SizedBox(height: TalabatiSpacing.xs),
                Text(
                  formattedValue,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHighlightCard(BuildContext context, double thisMonthRevenue, double monthlyTarget, double ratio) {
    final formattedRevenue = '${NumberFormat('#,###', 'en_US').format(thisMonthRevenue)} DA';
    final formattedTarget = NumberFormat('#,###', 'en_US').format(monthlyTarget);
    final percentage = (ratio * 100).round();

    return Container(
      width: double.infinity,
      padding: TalabatiSpacing.cardPadding,
      decoration: BoxDecoration(
        color: TalabatiColors.surfaceDark,
        borderRadius: TalabatiRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THIS MONTH REVENUE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: TalabatiSpacing.sm),
                  Text(
                    formattedRevenue,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: TalabatiSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: $formattedTarget DA',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '$percentage% Reached',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: TalabatiSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderListItem(BuildContext context, RecentOrderStat order) {
    final themeStatus = theme.OrderStatus.values.byName(order.status.name);
    final statusBadge = StatusBadge(
      label: themeStatus.label,
      backgroundColor: themeStatus.backgroundColor,
      textColor: themeStatus.textColor,
    );

    
    final formattedAmount = '${NumberFormat('#,###', 'en_US').format(order.totalAmount)} DA';

    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TalabatiSpacing.base,
          vertical: TalabatiSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: TalabatiColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: TalabatiColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: TalabatiSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.clientName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${order.wilaya}, DZ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                statusBadge,
                const SizedBox(height: TalabatiSpacing.xs),
                Text(
                  formattedAmount,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
