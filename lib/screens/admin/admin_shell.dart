import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/admin_providers.dart';

class AdminShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AdminShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingReservationsAdminProvider).value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: navigationShell,
      bottomNavigationBar: _AdminNav(
        currentIndex: navigationShell.currentIndex,
        pendingCount: pendingCount,
        onTap: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
      ),
    );
  }
}

class _AdminNav extends StatelessWidget {
  final int currentIndex;
  final int pendingCount;
  final ValueChanged<int> onTap;
  const _AdminNav({required this.currentIndex, required this.pendingCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.dashboard_rounded, label: 'Dashboard', badge: 0),
      (icon: Icons.library_books_rounded, label: 'Documents', badge: 0),
      (icon: Icons.assignment_rounded, label: 'Emprunts', badge: pendingCount),
      (icon: Icons.people_rounded, label: 'Utilisateurs', badge: 0),
      (icon: Icons.settings_rounded, label: 'Paramètres', badge: 0),
    ];

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
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.purpleSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(item.icon, size: 22, color: active ? AppColors.purple : AppColors.textMuted),
                          if (item.badge > 0)
                            Positioned(
                              top: -4, right: -6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                child: Text('${item.badge}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(item.label, style: TextStyle(fontSize: 10, color: active ? AppColors.purple : AppColors.textMuted, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
