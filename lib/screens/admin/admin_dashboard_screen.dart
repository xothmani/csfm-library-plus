import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final stats = ref.watch(adminStatsProvider);
    final weeklyData = ref.watch(weeklyLoansProvider);
    final isAdmin = profile?.role == 'Administrateur';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0x0F9B7FD4),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vue d\'ensemble', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Dashboard', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.purpleSoft, borderRadius: BorderRadius.circular(10)),
                            child: Text(isAdmin ? '🔑 Administrateur' : '📚 Bibliothécaire', style: const TextStyle(color: AppColors.purple, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.purple, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Text('🔑', style: TextStyle(fontSize: 22))),
                    ),
                  ],
                ),
              ),

              // ── OVERDUE ALERT ──
              if (stats.overdueLoans > 0)
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
                  child: Row(
                    children: [
                      const Text('🚨', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${stats.overdueLoans} retard(s) en cours — Action requise', style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600))),
                      GestureDetector(onTap: () => context.go('/admin/loans'), child: const Text('Voir →', style: TextStyle(color: AppColors.error, fontSize: 12))),
                    ],
                  ),
                ),

              // ── KPI CARDS ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _KpiCard(emoji: '📚', count: stats.totalDocs, label: 'Documents', color: AppColors.accent, bg: AppColors.accentSoft),
                    _KpiCard(emoji: '🔄', count: stats.activeLoans, label: 'Emprunts actifs', color: AppColors.success, bg: AppColors.successSoft),
                    _KpiCard(emoji: '⚠️', count: stats.overdueLoans, label: 'En retard', color: AppColors.error, bg: AppColors.errorSoft),
                    _KpiCard(emoji: '👥', count: stats.totalUsers, label: 'Utilisateurs', color: AppColors.gold, bg: AppColors.goldSoft),
                  ],
                ),
              ),

              // ── WEEKLY CHART ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text('Emprunts / 7 jours', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _WeeklyChart(data: weeklyData),
              ),

              // ── QUICK ACTIONS ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text('Actions rapides', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _QuickAction(emoji: '➕', label: 'Ajouter doc', onTap: () => context.go('/admin/documents')),
                    _QuickAction(emoji: '✅', label: 'Valider emprunt', onTap: () => context.go('/admin/loans')),
                    _QuickAction(emoji: '🔄', label: 'Retour doc', onTap: () => context.go('/admin/loans')),
                    if (isAdmin) _QuickAction(emoji: '👤', label: 'Nouvel utilisateur', onTap: () => context.go('/admin/users')),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SUB-WIDGETS ──────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String emoji;
  final int count;
  final String label;
  final Color color;
  final Color bg;
  const _KpiCard({required this.emoji, required this.count, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16)))),
            const Spacer(),
            Text('$count', style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      );
}

class _WeeklyChart extends StatelessWidget {
  final List<int> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty ? 1 : (data.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, double.infinity));
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(data.length, (i) {
                final isLast = i == data.length - 1;
                final barH = (data[i] / maxVal * 80).clamp(4, 80).toDouble();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${data[i]}', style: TextStyle(color: isLast ? AppColors.accent : AppColors.textMuted, fontSize: 10)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 24, height: barH,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: isLast ? [AppColors.accent, AppColors.purple] : [AppColors.surfaceElevated, AppColors.surfaceElevated],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: days.map((d) => Text(d, style: const TextStyle(color: AppColors.textMuted, fontSize: 11))).toList()),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}
