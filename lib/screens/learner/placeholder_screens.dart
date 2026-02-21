import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_bottom_nav.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(child: Text('📋 Emprunts — Bientôt disponible', style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
        bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(child: Text('🔔 Alertes — Bientôt disponible', style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(child: Text('👤 Profil — Bientôt disponible', style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
        bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      );
}
