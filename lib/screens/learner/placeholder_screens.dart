import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/loans_provider.dart';
import '../../services/auth_service.dart';
import '../../models/reservation_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final stats = user != null
        ? ref.watch(userStatsProvider(user.uid)).value
        : null;

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
                  color: Color(0x0F4F8EF7),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?.fullName ?? 'Utilisateur',
                      style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    // Role & lodging badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Badge(text: profile?.role ?? 'Externe', color: AppColors.accent, bg: AppColors.accentSoft),
                        if (profile?.isLodged == true) ...[
                          const SizedBox(width: 8),
                          _Badge(text: '⭐ Logé · Prioritaire', color: AppColors.gold, bg: AppColors.goldSoft),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── STATS ────────────────────────────────────────────
              if (stats != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      _StatTile(value: '${stats.activeLoans}', label: 'En cours', emoji: '📖'),
                      _divider(),
                      _StatTile(value: '${stats.pendingReservations}', label: 'Réservés', emoji: '📌'),
                      _divider(),
                      _StatTile(value: '${stats.returnedLoans}', label: 'Retournés', emoji: '✅'),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ── SECTION: MON COMPTE ──────────────────────────────
              _SectionHeader(title: 'Mon compte'),
              _MenuItem(icon: Icons.person_outline_rounded, label: 'Modifier le profil', onTap: () => _showEditProfileSheet(context, profile?.fullName ?? '')),
              _MenuItem(icon: Icons.lock_outline_rounded, label: 'Changer le mot de passe', onTap: () => _showChangePasswordSheet(context)),
              _MenuItem(icon: Icons.badge_outlined, label: 'Mon identifiant', trailing: Text(user?.uid.substring(0, 8) ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'monospace')), onTap: () {}),

              const SizedBox(height: 8),

              // ── SECTION: PRÉFÉRENCES ─────────────────────────────
              _SectionHeader(title: 'Préférences'),
              _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', trailing: const _Toggle(), onTap: () {}),
              _MenuItem(icon: Icons.language_rounded, label: 'Langue', trailing: const Text('Français', style: TextStyle(color: AppColors.textMuted, fontSize: 13)), onTap: () {}),

              const SizedBox(height: 8),

              // ── SECTION: À PROPOS ────────────────────────────────
              _SectionHeader(title: 'À propos'),
              _MenuItem(icon: Icons.info_outline_rounded, label: 'Version de l\'app', trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 13)), onTap: () {}),
              _MenuItem(icon: Icons.school_rounded, label: 'CSFM Nabeul', trailing: const Text('Bibliothèque+', style: TextStyle(color: AppColors.textMuted, fontSize: 13)), onTap: () {}),

              const SizedBox(height: 24),

              // ── LOGOUT BUTTON ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => _confirmLogout(context, ref),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Text('Se déconnecter', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _divider() => Container(width: 1, height: 40, color: AppColors.border);

  void _confirmLogout(BuildContext context, WidgetRef ref) {
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
            const Text('Vous devrez vous reconnecter pour accéder à la bibliothèque.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
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

  void _showEditProfileSheet(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Modifier le profil', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Nom complet', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]), borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Changer le mot de passe', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Un email de réinitialisation sera envoyé à votre adresse.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]), borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('Envoyer le lien', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SUB-WIDGETS ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Badge({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  const _StatTile({required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
        child: Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
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
                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
              trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      );
}

class _Toggle extends StatefulWidget {
  const _Toggle();
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _on = true;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => setState(() => _on = !_on),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44, height: 26,
          decoration: BoxDecoration(
            color: _on ? AppColors.accent : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(13),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(3),
              width: 20, height: 20,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      );
}
