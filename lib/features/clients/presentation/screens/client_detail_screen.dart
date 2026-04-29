import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';
import 'package:talabati/features/clients/presentation/screens/add_edit_client_screen.dart';
import 'package:talabati/features/orders/data/models/order.dart';
import 'package:talabati/features/orders/data/models/order_status.dart';
import 'package:talabati/features/orders/presentation/screens/order_detail_placeholder_screen.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final client = clients.firstWhere((c) => c.id == clientId, orElse: () => throw Exception('Client not found'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditClientScreen(client: client),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildClientInfoCard(client),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Order History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildOrderHistory(ref, client),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(Client client) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, 'Name', client.name),
            _buildInfoRow(Icons.phone, 'Phone', client.phone),
            _buildInfoRow(Icons.location_on, 'Wilaya', client.wilaya),
            if (client.instagramHandle != null)
              _buildInfoRow(Icons.camera_alt, 'Instagram', '@${client.instagramHandle}'),
            if (client.notes != null)
              _buildInfoRow(Icons.note, 'Notes', client.notes!),
            _buildInfoRow(Icons.refresh, 'Returns', '${client.returnCount} orders returned'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistory(WidgetRef ref, Client client) {
    final repository = ref.read(clientsRepositoryProvider);

    return FutureBuilder<List<Order>>(
      future: repository.getClientOrders(client.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No orders yet'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text(DateFormat('MMM dd, yyyy').format(order.createdAt)),
              subtitle: Text(order.status.label),
              trailing: Text(
                NumberFormat.currency(symbol: 'DA').format(order.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailPlaceholderScreen(orderId: order.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
