import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talabati/core/theme/app_colors.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';
import 'package:talabati/features/clients/presentation/screens/add_edit_client_screen.dart';
import 'package:talabati/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

const _whatsappGreen = Color(0xFF25D366);
const _instagramPink = Color(0xFFE1306C);

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(filteredClientsProvider);
    final allClients = ref.watch(clientsProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ClientsHeader(totalClients: allClients.length, ref: ref),
          const SizedBox(height: 26),
          Expanded(
            child: clients.isEmpty
                ? const Center(child: Text('No clients found'))
                : ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: 92 + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      return _ClientCard(client: clients[index]);
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
            MaterialPageRoute(
              builder: (context) => const AddEditClientScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Client',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ClientsHeader extends StatelessWidget {
  final int totalClients;
  final WidgetRef ref;

  const _ClientsHeader({required this.totalClients, required this.ref});

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
                  'Clients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalClients clients',
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
            hint: 'Search by name or phone...',
            onChanged: (value) =>
                ref.read(searchClientQueryProvider.notifier).state = value,
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

class _ClientCard extends ConsumerWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                builder: (context) => ClientDetailScreen(clientId: client.id),
              ),
            );
          },
          onLongPress: () => _confirmDelete(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accentLight,
                  child: Text(
                    _initials(client.name),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${client.wilaya} • ${client.phone}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (client.returnCount >= 3) ...[
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '⚠ Returns: ${client.returnCount}',
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                      icon: Icons.phone,
                      color: AppColors.textSecondary,
                      onTap: () => _launchPhone(context, client.phone),
                    ),
                    _SvgActionIcon(
                      asset: 'assets/icons/social/whatsapp.svg',
                      color: _whatsappGreen,
                      onTap: () => _launchWhatsApp(context, client.phone),
                    ),
                    if (client.instagramHandle != null &&
                        client.instagramHandle!.trim().isNotEmpty)
                      _SvgActionIcon(
                        asset: 'assets/icons/social/instagram.svg',
                        color: _instagramPink,
                        onTap: () =>
                            _launchInstagram(context, client.instagramHandle!),
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1].substring(0, 1)
        : '';
    return (first + second).toUpperCase();
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(clientsProvider.notifier).deleteClient(client.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        icon: Icon(icon, color: color, size: 19),
        onPressed: onTap,
      ),
    );
  }
}

class _SvgActionIcon extends StatelessWidget {
  final String asset;
  final Color color;
  final VoidCallback onTap;

  const _SvgActionIcon({
    required this.asset,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        icon: SvgPicture.asset(
          asset,
          width: 19,
          height: 19,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        onPressed: onTap,
      ),
    );
  }
}
