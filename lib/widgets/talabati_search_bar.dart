import 'package:flutter/material.dart';
import 'package:talabati/theme/talabati_theme.dart';

class TalabatiSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const TalabatiSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
