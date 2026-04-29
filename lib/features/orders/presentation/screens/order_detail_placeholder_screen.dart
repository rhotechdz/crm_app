import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';
import 'package:talabati/features/orders/data/models/delivery_company.dart';
import 'package:talabati/features/orders/data/models/order.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/data/models/order_with_client.dart';
import 'package:talabati/features/orders/presentation/order_ui_helpers.dart';
import 'package:talabati/features/orders/presentation/providers/orders_provider.dart';
import 'package:talabati/features/orders/presentation/screens/add_edit_order_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPlaceholderScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailPlaceholderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersProvider);
    final entry = _findOrder(state.orders, orderId);

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return _OrderDetailContent(entry: entry);
  }

  OrderWithClient? _findOrder(List<OrderWithClient> orders, String id) {
    for (final entry in orders) {
      if (entry.order.id == id) return entry;
    }
    return null;
  }
}

class _OrderDetailContent extends ConsumerStatefulWidget {
  final OrderWithClient entry;

  const _OrderDetailContent({required this.entry});

  @override
  ConsumerState<_OrderDetailContent> createState() =>
      _OrderDetailContentState();
}

class _OrderDetailContentState extends ConsumerState<_OrderDetailContent> {
  late TextEditingController _collectAmountController;
  late TextEditingController _returnReasonController;
  bool _isCollecting = false;
  bool _isReturning = false;

  @override
  void initState() {
    super.initState();
    _collectAmountController = TextEditingController(
      text: widget.entry.order.totalAmount.toStringAsFixed(0),
    );
    _returnReasonController = TextEditingController();
  }

  @override
  void dispose() {
    _collectAmountController.dispose();
    _returnReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.entry.order;
    final currencyFormat = NumberFormat.currency(symbol: 'DA');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/social/whatsapp.svg',
              width: 22,
              height: 22,
            ),
            onPressed: widget.entry.clientPhone.isEmpty
                ? null
                : () => _launchWhatsApp(context, widget.entry.clientPhone),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditOrderScreen(orderEntry: widget.entry),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: OrderStatusChip(status: order.status, large: true)),
            const SizedBox(height: 8),
            _buildConfirmationRow(order),
            const SizedBox(height: 16),
            _buildClientCard(),
            const SizedBox(height: 12),
            _buildItemsCard(order, currencyFormat),
            const SizedBox(height: 12),
            _buildDeliveryCard(order, currencyFormat, dateFormat),
            const SizedBox(height: 12),
            _buildNotesCard(order),
            const SizedBox(height: 88),
          ],
        ),
      ),
      bottomNavigationBar: _buildStatusActions(context, ref, order),
    );
  }

  Widget _buildConfirmationRow(Order order) {
    final confirmed = order.isConfirmedByPhone;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          confirmed ? Icons.check_circle : Icons.warning,
          color: confirmed ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          confirmed ? 'Confirmed by phone' : 'Not confirmed by phone',
          style: TextStyle(
            color: confirmed ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.person, 'Name', widget.entry.clientName),
            _infoRow(Icons.phone, 'Phone', widget.entry.clientPhone),
            _infoRow(Icons.location_on, 'Wilaya', widget.entry.clientWilaya),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(Order order, NumberFormat currencyFormat) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.unitPrice * item.quantity,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final item in order.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName),
                subtitle: Text(
                  [
                    if (item.variantLabel != null) item.variantLabel!,
                    '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                  ].join(' - '),
                ),
                trailing: Text(
                  currencyFormat.format(item.quantity * item.unitPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const Divider(),
            _amountRow('Subtotal', currencyFormat.format(subtotal)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
    Order order,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on, 'Wilaya', order.wilaya),
            _infoRow(
              Icons.local_shipping,
              'Company',
              order.deliveryCompany.label,
            ),
            _infoRow(
              Icons.receipt_long,
              'Created',
              dateFormat.format(order.createdAt),
            ),
            if (order.trackingNumber != null)
              _infoRow(
                Icons.confirmation_number,
                'Tracking',
                order.trackingNumber!,
              ),
            const Divider(),
            _amountRow(
              'Delivery fee',
              currencyFormat.format(order.deliveryFee),
            ),
            _amountRow(
              'Total',
              currencyFormat.format(order.totalAmount),
              isBold: true,
            ),
            if (order.amountCollected != null)
              _amountRow(
                'Collected',
                currencyFormat.format(order.amountCollected),
                isBold: true,
              ),
            if (order.returnReason != null) ...[
              const Divider(),
              _infoRow(
                Icons.assignment_return,
                'Return reason',
                order.returnReason!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(order.notes ?? 'No notes'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActions(BuildContext context, WidgetRef ref, Order order) {
    final terminal =
        order.status == OrderStatus.collected ||
        order.status == OrderStatus.returned ||
        order.status == OrderStatus.cancelled;

    if (terminal) {
      return const SizedBox.shrink();
    }

    if (_isCollecting) {
      return _buildCollectedAmountEditor(ref, order);
    }

    if (_isReturning) {
      return _buildReturnReasonEditor(ref, order);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_nextStatus(order.status) != null)
              ElevatedButton(
                onPressed: () => _handleNextAction(context, ref, order),
                child: Text(_nextActionLabel(order.status)!),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _returnReasonController.clear();
                      setState(() {
                        _isCollecting = false;
                        _isReturning = true;
                      });
                    },
                    child: const Text('Mark as Returned'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateStatus(ref, order.id, OrderStatus.cancelled),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectedAmountEditor(WidgetRef ref, Order order) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _collectAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount Collected',
                suffixText: 'DA',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isCollecting = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveCollectedAmount(ref, order),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnReasonEditor(WidgetRef ref, Order order) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _returnReasonController,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Return Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isReturning = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveReturnReason(ref, order),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNextAction(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    if (order.status == OrderStatus.delivered) {
      _collectAmountController.text = order.totalAmount.toStringAsFixed(0);
      setState(() {
        _isReturning = false;
        _isCollecting = true;
      });
      return;
    }

    final nextStatus = _nextStatus(order.status);
    if (nextStatus != null) {
      await _updateStatus(ref, order.id, nextStatus);
    }
  }

  OrderStatus? _nextStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return OrderStatus.called;
      case OrderStatus.called:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.handedToCourier;
      case OrderStatus.handedToCourier:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
        return OrderStatus.collected;
      case OrderStatus.collected:
      case OrderStatus.returned:
      case OrderStatus.cancelled:
        return null;
    }
  }

  String? _nextActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'Mark as Called';
      case OrderStatus.called:
        return 'Mark as Confirmed';
      case OrderStatus.confirmed:
        return 'Hand to Courier';
      case OrderStatus.handedToCourier:
        return 'Mark as Delivered';
      case OrderStatus.delivered:
        return 'Mark as Collected';
      case OrderStatus.collected:
      case OrderStatus.returned:
      case OrderStatus.cancelled:
        return null;
    }
  }

  Future<void> _saveReturnReason(WidgetRef ref, Order order) async {
    final reason = _returnReasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a return reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await _updateStatus(
      ref,
      order.id,
      OrderStatus.returned,
      returnReason: reason,
    );
    ref.read(clientsProvider.notifier).loadClients();

    if (mounted) {
      setState(() => _isReturning = false);
    }
  }

  Future<void> _saveCollectedAmount(WidgetRef ref, Order order) async {
    final amount = double.tryParse(_collectAmountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await _updateStatus(
      ref,
      order.id,
      OrderStatus.collected,
      amountCollected: amount,
    );

    if (mounted) {
      setState(() => _isCollecting = false);
    }
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    String orderId,
    OrderStatus status, {
    String? returnReason,
    double? amountCollected,
  }) async {
    await ref
        .read(ordersProvider.notifier)
        .updateOrderStatus(
          orderId,
          status,
          returnReason: returnReason,
          amountCollected: amountCollected,
        );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final normalized = _whatsAppPhone(phone);
    final uri = Uri.parse('https://wa.me/$normalized');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  String _whatsAppPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    while (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.startsWith('213')) {
      return digits;
    }
    return '213$digits';
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
