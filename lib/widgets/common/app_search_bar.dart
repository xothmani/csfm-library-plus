import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hint = 'Rechercher un livre, auteur...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: readOnly
                  ? Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 15))
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      autofocus: !readOnly,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
            ),
            const Icon(Icons.tune_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
