import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/active_loans_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/loans/loan_widgets.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});
  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final activeLoans = ref.watch(activeLoansProvider(user.uid)).value ?? [];
    final historyLoans = ref.watch(loanHistoryProvider(user.uid)).value ?? [];
    final hasOverdue = activeLoans.any((l) => l.isOverdue || l.status == 'overdue');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes Emprunts', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Suivez vos emprunts et historique', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                  // Tab switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        _Tab(label: 'En cours (${activeLoans.length})', active: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                        const SizedBox(width: 4),
                        _Tab(label: 'Historique (${historyLoans.length})', active: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CONTENT
            Expanded(
              child: _tabIndex == 0
                  ? _ActiveTab(loans: activeLoans, hasOverdue: hasOverdue)
                  : _HistoryTab(loans: historyLoans),
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
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
            ),
          ),
        ),
      );
}

// ── ACTIVE TAB ──
class _ActiveTab extends StatelessWidget {
  final List loans;
  final bool hasOverdue;
  const _ActiveTab({required this.loans, required this.hasOverdue});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return const EmptyState(emoji: '📭', title: 'Aucun emprunt en cours', subtitle: 'Réservez un document dans le catalogue pour commencer');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: loans.length + (hasOverdue ? 1 : 0),
      itemBuilder: (context, i) {
        if (hasOverdue && i == loans.length) return const OverdueAlertBanner();
        final loan = loans[i];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('documents').doc(loan.documentId).get(),
          builder: (context, snap) {
            if (!snap.hasData || !snap.data!.exists) return const SizedBox(height: 80);
            final doc = DocumentModel.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id);
            return LoanCard(loan: loan, document: doc);
          },
        );
      },
    );
  }
}

// ── HISTORY TAB ──
class _HistoryTab extends StatelessWidget {
  final List loans;
  const _HistoryTab({required this.loans});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return const EmptyState(emoji: '📚', title: 'Aucun historique', subtitle: 'Vos emprunts passés apparaîtront ici');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: loans.length,
      itemBuilder: (context, i) {
        final loan = loans[i];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('documents').doc(loan.documentId).get(),
          builder: (context, snap) {
            if (!snap.hasData || !snap.data!.exists) return const SizedBox(height: 60);
            final doc = DocumentModel.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id);
            return HistoryLoanItem(loan: loan, document: doc);
          },
        );
      },
    );
  }
}
