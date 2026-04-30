import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';

class TalabatiActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? iconColor;
  final Color? backgroundColor;

  const TalabatiActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isPrimary ? TalabatiColors.primary : TalabatiColors.surface),
        shape: BoxShape.circle,
        border: (isPrimary || backgroundColor != null) ? null : Border.all(color: TalabatiColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            icon,
            color: iconColor ?? (isPrimary ? Colors.white : TalabatiColors.textSecondary),
            size: 20,
          ),
        ),
      ),
    );
  }
}
