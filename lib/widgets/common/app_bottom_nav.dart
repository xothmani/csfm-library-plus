import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  static const _routes = ['/home', '/catalogue', '/loans', '/notifications', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Accueil', index: 0, current: currentIndex, route: _routes[0]),
              _NavItem(icon: Icons.menu_book_rounded, label: 'Catalogue', index: 1, current: currentIndex, route: _routes[1]),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'Emprunts', index: 2, current: currentIndex, route: _routes[2]),
              _NavItem(icon: Icons.notifications_rounded, label: 'Alertes', index: 3, current: currentIndex, route: _routes[3]),
              _NavItem(icon: Icons.person_rounded, label: 'Profil', index: 4, current: currentIndex, route: _routes[4]),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final String route;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.route});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? AppColors.accent : AppColors.textMuted),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.accent : AppColors.textMuted, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
