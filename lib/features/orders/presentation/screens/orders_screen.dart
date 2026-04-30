import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talabati/theme/talabati_theme.dart' hide OrderStatus;
import 'package:talabati/theme/talabati_theme.dart' as theme;
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/talabati_search_bar.dart';
import 'package:talabati/widgets/talabati_filter_chips.dart';
import 'package:talabati/widgets/status_badge.dart';
import 'package:talabati/widgets/talabati_action_button.dart';
import 'package:talabati/features/orders/presentation/providers/orders_provider.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/data/models/order_with_client.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  late final List<String> _filters;
  late final List<theme.OrderStatus?> _filterValues;

  @override
  void initState() {
    super.initState();
    _filters = ['All', ...theme.OrderStatus.values.map((s) => s.label)];
    _filterValues = [null, ...theme.OrderStatus.values];
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final allOrders = ordersState.orders;

    final theme.OrderStatus? selectedStatus = _filterValues[_selectedFilterIndex];

    final filteredList = allOrders.where((entry) {
      final order = entry.order;
      if (selectedStatus != null && order.status.name != selectedStatus.name) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final trackingNumber = (order.trackingNumber ?? '').toLowerCase();
        final clientName = entry.clientName.toLowerCase();
        final clientPhone = entry.clientPhone.toLowerCase();

        if (!clientName.contains(query) &&
            !clientPhone.contains(query) &&
            !trackingNumber.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

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
                  '${allOrders.length} Total Orders Today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TalabatiSpacing.lg),
                TalabatiSearchBar(
                  hintText: 'Search by client, phone or tracking ID',
                  onChanged: (val) => setState(() => _searchQuery = val),
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
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.base),
              itemBuilder: (context, index) {
                return _OrderCard(entry: filteredList[index]);
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

class _OrderCard extends ConsumerWidget {
  final OrderWithClient entry;

  const _OrderCard({required this.entry});

  void _showStatusBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Change Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...theme.OrderStatus.values.map((status) {
                return ListTile(
                  leading: StatusBadge(
                    label: status.label,
                    backgroundColor: status.backgroundColor,
                    textColor: status.textColor,
                  ),
                  title: Text(status.label),
                  onTap: () {
                    final modelStatus = OrderStatus.values.byName(status.name);
                    ref.read(ordersProvider.notifier).updateOrderStatus(
                          entry.order.id,
                          modelStatus,
                        );
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = entry.order;
    final themeStatus = theme.OrderStatus.values.byName(order.status.name);
    final formattedAmount = '${NumberFormat('#,###', 'en_US').format(order.totalAmount)} DA';
    final formattedDate = DateFormat('MMM d, yyyy').format(order.createdAt);

    return Card(
      child: Padding(
        padding: TalabatiSpacing.cardPadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.clientName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                StatusBadge(
                  label: themeStatus.label,
                  backgroundColor: themeStatus.backgroundColor,
                  textColor: themeStatus.textColor,
                ),
              ],
            ),
            const SizedBox(height: TalabatiSpacing.md),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.xs),
                Text('${entry.clientWilaya}, DZ', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: TalabatiSpacing.lg),
                const Icon(Icons.calendar_today_outlined, size: 14, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.xs),
                Text(formattedDate, style: Theme.of(context).textTheme.bodyMedium),
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
                      formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                TalabatiActionButton(
                  icon: Icons.phone_enabled_rounded,
                  onTap: () {
                    final uri = Uri.parse('tel:${entry.clientPhone}');
                    launchUrl(uri);
                  },
                ),
                const SizedBox(width: TalabatiSpacing.sm),
                TalabatiActionButton(
                  icon: FontAwesomeIcons.whatsapp,
                  isPrimary: false,
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onTap: () {
                    // WhatsApp scheme to open chat
                    final phone = entry.clientPhone.replaceAll(RegExp(r'[^\d+]'), '');
                    // For Algeria, typically start with +213 if not already
                    final formattedPhone = phone.startsWith('0') 
                        ? '+213${phone.substring(1)}' 
                        : phone;
                    final uri = Uri.parse('whatsapp://send?phone=$formattedPhone');
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
                const SizedBox(width: TalabatiSpacing.sm),
                TalabatiActionButton(
                  icon: Icons.more_vert,
                  isPrimary: false,
                  onTap: () => _showStatusBottomSheet(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
