import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';

class TalabatiFilterChips extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final Function(int) onSelected;

  const TalabatiFilterChips({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: TalabatiSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return ChoiceChip(
            label: Text(options[index]),
            selected: isSelected,
            onSelected: (_) => onSelected(index),
            backgroundColor: TalabatiColors.surface,
            selectedColor: TalabatiColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : TalabatiColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected ? TalabatiColors.primary : TalabatiColors.border,
            ),
            shape: const StadiumBorder(),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
