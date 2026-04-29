import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';
import 'package:talabati/features/clients/presentation/screens/add_edit_client_screen.dart';
import 'package:talabati/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(filteredClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) =>
                  ref.read(searchClientQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
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
        ),
      ),
      body: clients.isEmpty
          ? const Center(child: Text('No clients found'))
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(client.name),
                      if (client.returnCount >= 3) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '⚠ Frequent returner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('${client.wilaya} • ${client.phone}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Call',
                        icon: const Icon(Icons.phone),
                        onPressed: () => _launchPhone(context, client.phone),
                      ),
                      IconButton(
                        tooltip: 'WhatsApp',
                        icon: SvgPicture.asset(
                          'assets/icons/social/whatsapp.svg',
                          width: 22,
                          height: 22,
                        ),
                        onPressed: () => _launchWhatsApp(context, client.phone),
                      ),
                      if (client.instagramHandle != null &&
                          client.instagramHandle!.trim().isNotEmpty)
                        IconButton(
                          tooltip: 'Instagram',
                          icon: SvgPicture.asset(
                            'assets/icons/social/instagram.svg',
                            width: 22,
                            height: 22,
                          ),
                          onPressed: () => _launchInstagram(
                            context,
                            client.instagramHandle!,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClientDetailScreen(clientId: client.id),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Client'),
                        content: Text(
                          'Are you sure you want to delete ${client.name}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(clientsProvider.notifier)
                                  .deleteClient(client.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditClientScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
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

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final uri = Uri.parse('https://wa.me/${_algeriaPhone(phone)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchInstagram(BuildContext context, String handle) async {
    final cleanHandle = handle.trim().replaceFirst(RegExp(r'^@+'), '');
    final uri = Uri.parse('https://ig.me/m/$cleanHandle');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Instagram DMs')),
        );
      }
    }
  }

  String _algeriaPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    while (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.startsWith('213')) {
      return digits;
    }
    return '213$digits';
  }
}
