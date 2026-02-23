import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin_providers.dart';
import '../../services/auth_service.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final stats = ref.watch(adminStatsProvider);
    final isAdmin = profile?.role == 'Administrateur';
    final initials = _initials(profile?.fullName ?? user?.email ?? '?');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── HEADER ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: const BoxDecoration(
                  color: Color(0x0F9B7FD4),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.purple, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppColors.purple.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile?.fullName ?? 'Administrateur',
                      style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.purpleSoft, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        isAdmin ? '🔑 Administrateur' : '📚 Bibliothécaire',
                        style: const TextStyle(color: AppColors.purple, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              // ── QUICK STATS ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    _StatTile(value: '${stats.totalDocs}', label: 'Documents', emoji: '📚'),
                    const SizedBox(width: 12),
                    _StatTile(value: '${stats.activeLoans}', label: 'Emprunts', emoji: '🔄'),
                    const SizedBox(width: 12),
                    _StatTile(value: '${stats.totalUsers}', label: 'Utilisateurs', emoji: '👥'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── SECTION: MON COMPTE ──────────────────────────────
              _SectionLabel('Mon compte'),
              _MenuItem(icon: Icons.person_outline_rounded, label: 'Informations du profil', trailing: Text(profile?.role ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), onTap: () {}),
              _MenuItem(icon: Icons.email_outlined, label: 'Adresse email', trailing: Text(user?.email?.substring(0, (user.email?.length ?? 0).clamp(0, 18)) ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), onTap: () {}),
              _MenuItem(icon: Icons.lock_outline_rounded, label: 'Changer le mot de passe', onTap: () => _sendPasswordReset(context, user?.email ?? '')),

              const SizedBox(height: 8),

              // ── SECTION: GESTION ─────────────────────────────────
              _SectionLabel('Gestion'),
              _MenuItem(icon: Icons.library_books_rounded, label: 'Documents', onTap: () => context.go('/admin/documents')),
              _MenuItem(icon: Icons.assignment_rounded, label: 'Emprunts & réservations', onTap: () => context.go('/admin/loans')),
              _MenuItem(icon: Icons.people_rounded, label: 'Utilisateurs', onTap: () => context.go('/admin/users')),

              const SizedBox(height: 8),

              // ── SECTION: À PROPOS ────────────────────────────────
              _SectionLabel('À propos'),
              _MenuItem(icon: Icons.info_outline_rounded, label: 'Version', trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 13)), onTap: () {}),
              _MenuItem(icon: Icons.school_rounded, label: 'CSFM Nabeul', trailing: const Text('Bibliothèque+', style: TextStyle(color: AppColors.textMuted, fontSize: 13)), onTap: () {}),

              const SizedBox(height: 24),

              // ── LOGOUT BUTTON ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Text('Se déconnecter', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _sendPasswordReset(BuildContext context, String email) async {
    if (email.isEmpty) return;
    try {
      await AuthService().sendPasswordResetEmail(email);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📧 Email de réinitialisation envoyé'), backgroundColor: AppColors.success));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error));
    }
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('🚪', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('Se déconnecter ?', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Vous quitterez le panneau administrateur.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('Annuler', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await AuthService().signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
                      child: const Center(child: Text('Déconnecter', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  const _StatTile({required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
        child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.purpleSoft, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 17, color: AppColors.purple),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
              trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      );
}
