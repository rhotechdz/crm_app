import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';

class TalabatiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showHamburger;
  final bool showAvatar;

  const TalabatiAppBar({
    super.key,
    required this.title,
    this.showHamburger = true,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TalabatiColors.background,
      elevation: 0,
      leading: showHamburger
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {},
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: TalabatiColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        if (showAvatar)
          const Padding(
            padding: EdgeInsets.only(right: TalabatiSpacing.base),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: TalabatiColors.badgeNeutralBg,
              child: Icon(Icons.person, color: TalabatiColors.textSecondary),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
