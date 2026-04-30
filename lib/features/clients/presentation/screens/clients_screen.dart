import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/talabati_search_bar.dart';
import 'package:talabati/widgets/talabati_action_button.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/clients/presentation/screens/add_edit_client_screen.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);

    final filteredList = clients.where((c) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatches = c.name.toLowerCase().contains(query);
        final phoneMatches = c.phone.toLowerCase().contains(query);
        if (!nameMatches && !phoneMatches) {
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
                  'Clients',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${clients.length} Total Registered Clients',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TalabatiSpacing.lg),
                TalabatiSearchBar(
                  hintText: 'Search by name or phone...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: TalabatiColors.surface,
                            borderRadius: BorderRadius.circular(TalabatiRadius.lg),
                          ),
                          child: const Icon(
                            Icons.people_outline_rounded,
                            size: 36,
                            color: TalabatiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: TalabatiSpacing.lg),
                        Text(
                          clients.isEmpty ? "No clients yet" : "No results found",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: TalabatiSpacing.sm),
                        Text(
                          clients.isEmpty
                              ? "Add your first client to start\nmanaging their orders."
                              : "Try a different search term.",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.base),
                    itemBuilder: (context, index) {
                      return _ClientCard(client: filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditClientScreen()),
          );
        },
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final initialsWords = client.name.split(' ').where((w) => w.isNotEmpty).take(2);
    final initials = initialsWords.map((w) => w[0]).join().toUpperCase();

    final colors = [
      const Color(0xFFDDE3FF),
      const Color(0xFFD4F0E0),
      const Color(0xFFFFE8CC),
      const Color(0xFFFFD6D6),
      const Color(0xFFE8D6FF),
      const Color(0xFFD6F0FF),
    ];
    final avatarColor = colors[client.id.hashCode.abs() % 6];

    final showWarning = client.returnCount >= 3;

    return Card(
      child: Padding(
        padding: TalabatiSpacing.cardPadding,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColor,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: TalabatiColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: TalabatiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              client.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showWarning) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: TalabatiColors.warning,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: TalabatiColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${client.wilaya}, DZ', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: TalabatiSpacing.xl),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 20, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.sm),
                Text(
                  client.phone,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TalabatiActionButton(
                  icon: Icons.phone_enabled_rounded,
                  isPrimary: false,
                  onTap: () {
                    final uri = Uri.parse('tel:${client.phone}');
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
                    final phone = client.phone.replaceAll(RegExp(r'\D'), '');
                    final formattedPhone = phone.startsWith('0') ? '213${phone.substring(1)}' : phone;
                    final uri = Uri.parse('https://wa.me/$formattedPhone');
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
                if (client.instagramHandle != null) ...[
                  const SizedBox(width: TalabatiSpacing.sm),
                  TalabatiActionButton(
                    icon: FontAwesomeIcons.instagram,
                    isPrimary: false,
                    onTap: () {
                      final uri = Uri.parse('https://instagram.com/${client.instagramHandle}');
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
