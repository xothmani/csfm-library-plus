import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.surface1,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient glow effect inside
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.5),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
          Icon(
            Icons.menu_book_rounded,
            size: size * 0.5,
            color: AppTheme.textPrimary,
          ),
        ],
      ),
    );
  }
}
