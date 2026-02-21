import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../models/loan_model.dart';
import '../../models/reservation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/documents_provider.dart';
import '../../providers/loans_provider.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/common/app_search_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/home/stat_card.dart';
import '../../widgets/home/active_loan_card.dart';
import '../../widgets/catalogue/book_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final docs = ref.watch(documentsProvider).value ?? [];
    final loans = user != null ? (ref.watch(userLoansProvider(user.uid)).value ?? []) : <LoanModel>[];
    final stats = user != null ? (ref.watch(userStatsProvider(user.uid)).value ?? UserStats.empty()) : UserStats.empty();
    final activeLoans = loans.where((l) => l.status == 'active').toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0x0F4F8EF7),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bonjour 👋', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                profile?.fullName ?? user?.email ?? 'Utilisateur',
                                style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(child: Text('🧑‍🎓', style: TextStyle(fontSize: 20))),
                        ),
                      ],
                    ),
                    if (profile?.isLodged == true) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: const Text('⭐ Apprenant Logé · Prioritaire', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // SEARCH BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: AppSearchBar(readOnly: true, onTap: () => context.go('/catalogue')),
              ),
            ),

            // MON ACTIVITÉ
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Text('Mon activité', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(child: StatCard(label: 'En cours', count: stats.activeLoans, emoji: '📖', color: AppColors.accent, bgColor: AppColors.accentSoft)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(label: 'Réservé', count: stats.pendingReservations, emoji: '📌', color: AppColors.gold, bgColor: AppColors.goldSoft)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(label: 'Retournés', count: stats.returnedLoans, emoji: '✅', color: AppColors.success, bgColor: AppColors.successSoft)),
                  ],
                ),
              ),
            ),

            // EMPRUNT EN COURS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Emprunt en cours', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => context.go('/loans'), child: const Text('Voir tout', style: TextStyle(color: AppColors.accent, fontSize: 13))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: activeLoans.isEmpty
                    ? const EmptyState(emoji: '📚', title: 'Aucun emprunt en cours', subtitle: 'Réservez un document dans le catalogue')
                    : _ActiveLoanFetcher(loan: activeLoans.first),
              ),
            ),

            // NOUVEAUTÉS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nouveautés', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => context.go('/catalogue'), child: const Text('Voir tout', style: TextStyle(color: AppColors.accent, fontSize: 13))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: docs.isEmpty
                  ? const EmptyState(emoji: '📦', title: 'Aucun document', subtitle: 'Le catalogue est vide pour l\'instant')
                  : SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: docs.take(10).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (_, i) => BookHorizontalCard(document: docs[i]),
                      ),
                    ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

// Fetches the document associated with an active loan
class _ActiveLoanFetcher extends StatelessWidget {
  final LoanModel loan;
  const _ActiveLoanFetcher({required this.loan});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('documents').doc(loan.documentId).get(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox(height: 80);
        final doc = DocumentModel.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id);
        return ActiveLoanCard(loan: loan, document: doc);
      },
    );
  }
}
