import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../models/reservation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/reservations/reservation_widgets.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    if (user == null) return const SizedBox.shrink();

    final activeRes = ref.watch(activeReservationsProvider(user.uid)).value ?? [];
    final pastRes = ref.watch(pastReservationsProvider(user.uid)).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Réservations', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${activeRes.length} réservation(s) active(s)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // PRIORITY BANNER
            if (profile?.isLodged == true)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Expanded(child: Text('En tant qu\'apprenant logé, vos réservations sont prioritaires.', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ),

            // ACTIVE SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text('En attente / Confirmées', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            activeRes.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: EmptyState(emoji: '📌', title: 'Aucune réservation active', subtitle: 'Réservez un document depuis le catalogue'),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _ResCardFetcher(reservation: activeRes[i]),
                      ),
                      childCount: activeRes.length,
                    ),
                  ),

            // PAST SECTION
            if (pastRes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text('Réservations passées', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _PastResItemFetcher(reservation: pastRes[i]),
                  ),
                  childCount: pastRes.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ResCardFetcher extends StatelessWidget {
  final ReservationModel reservation;
  const _ResCardFetcher({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('documents').doc(reservation.documentId).get(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox(height: 100);
        final d = DocumentModel.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id);
        return ReservationCard(reservation: reservation, bookTitle: d.title, bookAuthor: d.author, bookEmoji: d.categoryEmoji);
      },
    );
  }
}

class _PastResItemFetcher extends StatelessWidget {
  final ReservationModel reservation;
  const _PastResItemFetcher({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('documents').doc(reservation.documentId).get(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox(height: 60);
        final d = snap.data!.exists ? DocumentModel.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id) : null;
        return PastReservationItem(reservation: reservation, bookTitle: d?.title ?? 'Document inconnu', bookEmoji: d?.categoryEmoji ?? '📗');
      },
    );
  }
}
