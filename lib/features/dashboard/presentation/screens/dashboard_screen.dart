import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
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
                    value: '42',
                    badgeLabel: '+12%',
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
                    value: '08',
                    badgeLabel: 'URGENT',
                    badgeBg: TalabatiColors.dangerLight,
                    badgeText: TalabatiColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.base),
            
            // Total Revenue Card
            _buildTotalRevenueCard(context),
            const SizedBox(height: TalabatiSpacing.base),
            
            // Revenue Highlight Card
            _buildRevenueHighlightCard(context),
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
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.sm),
              itemBuilder: (context, index) {
                return _buildRecentOrderListItem(context);
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
    required String badgeLabel,
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
                StatusBadge(
                  label: badgeLabel,
                  backgroundColor: badgeBg,
                  textColor: badgeText,
                ),
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

  Widget _buildTotalRevenueCard(BuildContext context) {
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
                  '145,200 DA',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHighlightCard(BuildContext context) {
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
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: TalabatiSpacing.sm),
                  const Text(
                    '2,840,000 DA',
                    style: TextStyle(
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
                  color: Colors.white.withOpacity(0.1),
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
                'Target: 3.5M DA',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '81% Reached',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: TalabatiSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.81,
              backgroundColor: Colors.white.withOpacity(0.24),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderListItem(BuildContext context) {
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
                    'Ahmed Benali',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Algiers, DZ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(
                  label: OrderStatus.confirmed.label,
                  backgroundColor: OrderStatus.confirmed.backgroundColor,
                  textColor: OrderStatus.confirmed.textColor,
                ),
                const SizedBox(height: TalabatiSpacing.xs),
                Text(
                  '4,500 DA',
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
