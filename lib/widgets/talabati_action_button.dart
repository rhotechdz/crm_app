import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';

class TalabatiActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const TalabatiActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPrimary ? TalabatiColors.primary : TalabatiColors.surface,
        shape: BoxShape.circle,
        border: isPrimary ? null : Border.all(color: TalabatiColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : TalabatiColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
