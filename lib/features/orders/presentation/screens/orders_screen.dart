import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/talabati_search_bar.dart';
import 'package:talabati/widgets/talabati_filter_chips.dart';
import 'package:talabati/widgets/status_badge.dart';
import 'package:talabati/widgets/talabati_action_button.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All', 'New', 'Called', 'Confirmed', 'Handed', 'Delivered', 'Collected', 'Returned', 'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TalabatiAppBar(title: 'Talabati'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: TalabatiSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '128 Total Orders Today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TalabatiSpacing.lg),
                const TalabatiSearchBar(
                  hintText: 'Search by client, phone or tracking ID',
                ),
                const SizedBox(height: TalabatiSpacing.md),
                TalabatiFilterChips(
                  options: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (index) => setState(() => _selectedFilterIndex = index),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.base),
              itemBuilder: (context, index) {
                return const _OrderCard();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: TalabatiSpacing.cardPadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ahmed Benali',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                StatusBadge(
                  label: OrderStatus.handedToCourier.label,
                  backgroundColor: OrderStatus.handedToCourier.backgroundColor,
                  textColor: OrderStatus.handedToCourier.textColor,
                ),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.md),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.xs),
                Text('Algiers, DZ', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: TalabatiSpacing.lg),
                const Icon(Icons.calendar_today_outlined, size: 14, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.xs),
                Text('30 Apr, 2026', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.sm),
            Row(
              children: [
                const Icon(Icons.tag, size: 16, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.xs),
                Text('ORD-928347', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const Divider(height: TalabatiSpacing.xl),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '6,200 DA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                TalabatiActionButton(
                  icon: Icons.phone_enabled_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: TalabatiSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
