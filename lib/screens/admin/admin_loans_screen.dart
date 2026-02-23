import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../models/loan_model.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_providers.dart';

class AdminLoansScreen extends ConsumerStatefulWidget {
  const AdminLoansScreen({super.key});
  @override
  ConsumerState<AdminLoansScreen> createState() => _AdminLoansScreenState();
}

class _AdminLoansScreenState extends ConsumerState<AdminLoansScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingReservationsAdminProvider).value ?? [];
    final active = ref.watch(allActiveLoansAdminProvider).value ?? [];
    final overdue = ref.watch(overdueLoansAdminProvider).value ?? [];
    final adminUid = ref.watch(authStateProvider).value?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emprunts', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        _Tab(label: 'En attente (${pending.length})', active: _tab == 0, onTap: () => setState(() => _tab = 0)),
                        const SizedBox(width: 4),
                        _Tab(label: 'Actifs (${active.length})', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
                        const SizedBox(width: 4),
                        _Tab(label: '⚠ Retards (${overdue.length})', active: _tab == 2, onTap: () => setState(() => _tab = 2), isAlert: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: [
                _PendingTab(reservations: pending, adminUid: adminUid),
                _ActiveTab(loans: active),
                _OverdueTab(loans: overdue),
              ][_tab],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final bool isAlert;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap, this.isAlert = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? (isAlert ? AppColors.errorSoft : AppColors.accent) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(label, style: TextStyle(color: active ? (isAlert ? AppColors.error : Colors.white) : AppColors.textSecondary, fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center),
            ),
          ),
        ),
      );
}

// ── PENDING TAB — Validate or reject reservations ─────────────────────────
class _PendingTab extends StatelessWidget {
  final List<ReservationModel> reservations;
  final String adminUid;
  const _PendingTab({required this.reservations, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) return const Center(child: Text('✅ Aucune réservation en attente', style: TextStyle(color: AppColors.textMuted)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: reservations.length,
      itemBuilder: (_, i) => _PendingCard(reservation: reservations[i], adminUid: adminUid),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final ReservationModel reservation;
  final String adminUid;
  const _PendingCard({required this.reservation, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(reservation.userId).get(),
        FirebaseFirestore.instance.collection('documents').doc(reservation.documentId).get(),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox(height: 80);
        final user = snap.data![0].exists ? UserModel.fromMap(snap.data![0].data() as Map<String, dynamic>, snap.data![0].id) : null;
        final doc = snap.data![1].exists ? DocumentModel.fromMap(snap.data![1].data() as Map<String, dynamic>, snap.data![1].id) : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Row(
                children: [
                  // User avatar
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(_initials(user?.fullName ?? '?'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Utilisateur', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (user?.isLodged == true) _chip('⭐ Logé', AppColors.gold, AppColors.goldSoft),
                            if (user?.isLodged != true) _chip('Externe', AppColors.accent, AppColors.accentSoft),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (doc != null) Row(
                children: [
                  Text(doc.categoryEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(doc.title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (doc == null) return;
                        await validateLoan(reservationId: reservation.id, userId: reservation.userId, documentId: reservation.documentId, validatedBy: adminUid);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Emprunt validé!'), backgroundColor: AppColors.success));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.success.withValues(alpha: 0.4))),
                        child: const Center(child: Text('✅ Valider', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await FirebaseFirestore.instance.collection('reservations').doc(reservation.id).update({'status': 'cancelled'});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
                        child: const Center(child: Text('✗ Refuser', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── ACTIVE TAB ─────────────────────────────────────────────────────────────
class _ActiveTab extends StatelessWidget {
  final List<LoanModel> loans;
  const _ActiveTab({required this.loans});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) return const Center(child: Text('Aucun emprunt actif', style: TextStyle(color: AppColors.textMuted)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: loans.length,
      itemBuilder: (_, i) => _LoanAdminCard(loan: loans[i]),
    );
  }
}

// ── OVERDUE TAB ─────────────────────────────────────────────────────────────
class _OverdueTab extends StatelessWidget {
  final List<LoanModel> loans;
  const _OverdueTab({required this.loans});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) return const Center(child: Text('✅ Aucun retard', style: TextStyle(color: AppColors.success)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: loans.length,
      itemBuilder: (_, i) => _LoanAdminCard(loan: loans[i], isOverdueView: true),
    );
  }
}

class _LoanAdminCard extends StatelessWidget {
  final LoanModel loan;
  final bool isOverdueView;
  const _LoanAdminCard({required this.loan, this.isOverdueView = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(loan.userId).get(),
        FirebaseFirestore.instance.collection('documents').doc(loan.documentId).get(),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox(height: 80);
        final user = snap.data![0].exists ? UserModel.fromMap(snap.data![0].data() as Map<String, dynamic>, snap.data![0].id) : null;
        final doc = snap.data![1].exists ? DocumentModel.fromMap(snap.data![1].data() as Map<String, dynamic>, snap.data![1].id) : null;
        final overdue = loan.isOverdue || isOverdueView;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: overdue ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (doc != null) Text(doc.categoryEmoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc?.title ?? loan.documentId, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(user?.fullName ?? loan.userId, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: overdue ? AppColors.errorSoft : AppColors.successSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text(overdue ? '⚠ En retard' : 'Dans les délais', style: TextStyle(color: overdue ? AppColors.error : AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (loan.dueDate != null) Text('Retour: ${_fmt(loan.dueDate!)}', style: TextStyle(color: overdue ? AppColors.error : AppColors.textMuted, fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await returnBook(loanId: loan.id, documentId: loan.documentId);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📚 Retour enregistré!'), backgroundColor: AppColors.success));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))),
                      child: const Text('🔄 Marquer retourné', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
