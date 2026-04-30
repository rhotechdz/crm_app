import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/theme/talabati_theme.dart' hide OrderStatus;
import 'package:talabati/core/constants/wilayas.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';
import 'package:talabati/features/orders/data/models/delivery_company.dart';
import 'package:talabati/features/orders/data/models/order.dart';
import 'package:talabati/features/orders/data/models/order_item.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/data/models/order_with_client.dart';
import 'package:talabati/features/orders/presentation/providers/orders_provider.dart';
import 'package:talabati/features/orders/presentation/screens/product_picker_screen.dart';

class AddEditOrderScreen extends ConsumerStatefulWidget {
  final OrderWithClient? orderEntry;

  const AddEditOrderScreen({super.key, this.orderEntry});

  @override
  ConsumerState<AddEditOrderScreen> createState() => _AddEditOrderScreenState();
}

class _AddEditOrderScreenState extends ConsumerState<AddEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientSearchController;
  late TextEditingController _deliveryFeeController;
  late TextEditingController _trackingNumberController;
  late TextEditingController _notesController;

  String? _selectedClientId;
  String? _selectedWilaya;
  DeliveryCompany? _selectedDeliveryCompany;
  bool _isConfirmedByPhone = false;
  bool _isSaving = false;
  List<OrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.orderEntry?.order;
    _clientSearchController = TextEditingController();
    _deliveryFeeController = TextEditingController(
      text: existing?.deliveryFee.toStringAsFixed(0) ?? '0',
    );
    _trackingNumberController = TextEditingController(
      text: existing?.trackingNumber,
    );
    _notesController = TextEditingController(text: existing?.notes);
    _selectedClientId = existing?.clientId;
    _selectedWilaya = existing?.wilaya;
    _isConfirmedByPhone = existing?.isConfirmedByPhone ?? false;
    _items = List<OrderItem>.from(existing?.items ?? const []);

    // Set initial delivery company
    if (existing != null) {
      _selectedDeliveryCompany = existing.deliveryCompany;
    } else {
      // For new orders, use the last picked company from the provider
      _selectedDeliveryCompany = ref.read(ordersProvider).lastDeliveryCompany;
    }
  }

  @override
  void dispose() {
    _clientSearchController.dispose();
    _deliveryFeeController.dispose();
    _trackingNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);
  }

  double get _deliveryFee => double.tryParse(_deliveryFeeController.text) ?? 0;

  double get _total => _subtotal + _deliveryFee;

  Future<void> _addItem() async {
    final item = await Navigator.push<OrderItem>(
      context,
      MaterialPageRoute(builder: (context) => const ProductPickerScreen()),
    );

    if (item != null) {
      setState(() => _items.add(item));
    }
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity < 1) return;
    setState(() {
      final item = _items[index];
      _items[index] = OrderItem(
        productId: item.productId,
        productName: item.productName,
        variantLabel: item.variantLabel,
        quantity: quantity,
        unitPrice: item.unitPrice,
      );
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    if (_selectedClientId == null) {
      _showError('Select a client');
      return;
    }
    if (_items.isEmpty) {
      _showError('Add at least one item');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final existing = widget.orderEntry?.order;
    final order = Order(
      id: existing?.id,
      clientId: _selectedClientId!,
      items: _items,
      status: existing?.status ?? OrderStatus.newOrder,
      isConfirmedByPhone: _isConfirmedByPhone,
      wilaya: _selectedWilaya!,
      deliveryCompany: _selectedDeliveryCompany!,
      deliveryFee: _deliveryFee,
      trackingNumber: _trackingNumberController.text.trim().isEmpty
          ? null
          : _trackingNumberController.text.trim(),
      totalAmount: _total,
      amountCollected: existing?.amountCollected,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      returnReason: existing?.returnReason,
      createdAt: existing?.createdAt,
      updatedAt: DateTime.now(),
    );

    if (existing == null) {
      await ref.read(ordersProvider.notifier).addOrder(order);
    } else {
      await ref.read(ordersProvider.notifier).updateOrder(order);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);
    final selectedClient = _selectedClientId == null
        ? null
        : _findClient(clients, _selectedClientId!);
    final currencyFormat = NumberFormat.currency(symbol: 'DA');
    final isEditing = widget.orderEntry != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Order' : 'Add Order')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Client'),
              selectedClient == null
                  ? _buildClientPicker(clients)
                  : _buildSelectedClientCard(selectedClient),
              const SizedBox(height: 24),
              _buildItemsSection(currencyFormat),
              const SizedBox(height: 24),
              _buildDeliverySection(),
              const SizedBox(height: 24),
              _buildDetailsSection(),
              const SizedBox(height: 24),
              _buildTotalSection(currencyFormat),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TalabatiColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: TalabatiRadius.buttonRadius,
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(isEditing ? 'Update Order' : 'Save Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClientPicker(List<Client> clients) {
    final query = _clientSearchController.text.toLowerCase().trim();
    final filteredClients = clients.where((client) {
      return query.isEmpty ||
          client.name.toLowerCase().contains(query) ||
          client.phone.contains(query);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _clientSearchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search clients by name or phone...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (filteredClients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No clients found'),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  itemCount: filteredClients.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: TalabatiColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      title: Text(
                        client.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${client.phone} • ${client.wilaya}'),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        setState(() {
                          _selectedClientId = client.id;
                          _selectedWilaya = client.wilaya;
                          _clientSearchController.clear();
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedClientCard(Client client) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(client.name),
        subtitle: Text('${client.phone}\n${client.wilaya}'),
        isThreeLine: true,
        trailing: TextButton(
          onPressed: () => setState(() => _selectedClientId = null),
          child: const Text('Change'),
        ),
      ),
    );
  }

  Widget _buildItemsSection(NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Items'),
            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
        if (_items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No items added'),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var index = 0; index < _items.length; index++)
                  _buildItemTile(index, currencyFormat),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(
                        currencyFormat.format(_subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildItemTile(int index, NumberFormat currencyFormat) {
    final item = _items[index];
    return Dismissible(
      key: ValueKey('${item.productId}-${item.variantLabel}-$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeItem(index),
      child: ListTile(
        title: Text(item.productName),
        subtitle: Text(
          [
            if (item.variantLabel != null) item.variantLabel!,
            '${currencyFormat.format(item.unitPrice)} each',
            'Line: ${currencyFormat.format(item.unitPrice * item.quantity)}',
          ].join(' - '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _updateQuantity(index, item.quantity - 1),
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _updateQuantity(index, item.quantity + 1),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Delivery'),
        DropdownButtonFormField<String>(
          initialValue: _selectedWilaya,
          decoration: const InputDecoration(
            labelText: 'Wilaya*',
            border: OutlineInputBorder(),
          ),
          items: wilayas.map((wilaya) {
            return DropdownMenuItem(value: wilaya, child: Text(wilaya));
          }).toList(),
          onChanged: (value) => setState(() => _selectedWilaya = value),
          validator: (value) => value == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<DeliveryCompany>(
          initialValue: _selectedDeliveryCompany,
          decoration: const InputDecoration(
            labelText: 'Delivery Company*',
            border: OutlineInputBorder(),
          ),
          items: DeliveryCompany.values.map((company) {
            return DropdownMenuItem(value: company, child: Text(company.label));
          }).toList(),
          onChanged: (value) =>
              setState(() => _selectedDeliveryCompany = value),
          validator: (value) => value == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _deliveryFeeController,
          decoration: const InputDecoration(
            labelText: 'Delivery Fee',
            suffixText: 'DA',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: (value) =>
              double.tryParse(value ?? '') == null ? 'Invalid' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _trackingNumberController,
          decoration: const InputDecoration(
            labelText: 'Tracking Number (optional)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Order Details'),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Confirmed by phone'),
          value: _isConfirmedByPhone,
          onChanged: (value) => setState(() => _isConfirmedByPhone = value),
        ),
      ],
    );
  }

  Widget _buildTotalSection(NumberFormat currencyFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', currencyFormat.format(_subtotal)),
            _buildTotalRow('Delivery fee', currencyFormat.format(_deliveryFee)),
            const Divider(),
            _buildTotalRow(
              'Total',
              currencyFormat.format(_total),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 15,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Client? _findClient(List<Client> clients, String id) {
    for (final client in clients) {
      if (client.id == id) return client;
    }
    return null;
  }
}
