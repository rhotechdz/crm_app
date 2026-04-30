import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/widgets/talabati_app_bar.dart';
import 'package:talabati/widgets/talabati_search_bar.dart';
import 'package:talabati/widgets/talabati_filter_chips.dart';
import 'package:talabati/widgets/status_badge.dart';
import 'package:talabati/widgets/talabati_action_button.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'VIP', 'Recent', 'Inactive'];

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
                  'Clients',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '142 Total Registered Clients',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TalabatiSpacing.lg),
                const TalabatiSearchBar(
                  hintText: 'Search by name or phone...',
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
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: TalabatiSpacing.base),
              itemBuilder: (context, index) {
                final isVip = index == 0;
                final isHighReturn = index == 1;
                return _ClientCard(
                  name: isVip ? 'Fatim-Zahra Mansouri' : (isHighReturn ? 'Karim Belkacem' : 'Yacine Brahimi'),
                  initials: isVip ? 'FM' : (isHighReturn ? 'KB' : 'YB'),
                  status: isVip ? ClientStatus.vip : ClientStatus.active,
                  isHighReturn: isHighReturn,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final String name;
  final String initials;
  final ClientStatus status;
  final bool isHighReturn;

  const _ClientCard({
    required this.name,
    required this.initials,
    required this.status,
    this.isHighReturn = false,
  });

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFFEE2E2),
      const Color(0xFFFEF3C7),
      const Color(0xFFD1FAE5),
      const Color(0xFFDBEAFE),
      const Color(0xFFE0E7FF),
      const Color(0xFFF3E8FF),
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: TalabatiSpacing.cardPadding,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getAvatarColor(name),
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
                              name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isHighReturn) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: TalabatiColors.warning,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: TalabatiColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Oran, DZ', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: status.label,
                  backgroundColor: status.backgroundColor,
                  textColor: status.textColor,
                ),
              ],
            ),
            const Divider(height: TalabatiSpacing.xl),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 20, color: TalabatiColors.textSecondary),
                const SizedBox(width: TalabatiSpacing.sm),
                Text(
                  '0550 12 34 56',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TalabatiActionButton(
                  icon: Icons.phone_enabled_rounded,
                  onTap: () {},
                  isPrimary: false,
                ),
                const SizedBox(width: TalabatiSpacing.sm),
                TalabatiActionButton(
                  icon: Icons.chat_outlined,
                  onTap: () {},
                  isPrimary: false,
                ),
                const SizedBox(width: TalabatiSpacing.sm),
                TalabatiActionButton(
                  icon: Icons.receipt_long_outlined,
                  onTap: () {},
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
