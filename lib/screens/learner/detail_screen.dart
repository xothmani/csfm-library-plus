import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/documents_provider.dart';
import '../../providers/loans_provider.dart';
import '../../providers/active_loans_provider.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String documentId;
  const DetailScreen({super.key, required this.documentId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _reserving = false;

  Future<void> _reserve(DocumentModel doc, String userId) async {
    setState(() => _reserving = true);
    try {
      await createReservation(
          userId: userId, documentId: doc.id, availableCopies: doc.availableCopies);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Réservation effectuée !'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentDetailProvider(widget.documentId));
    final user = ref.watch(authStateProvider).value;

    // Watch reservation + loan status in real-time
    final existingReservation = user != null
        ? ref.watch(userDocReservationProvider((userId: user.uid, documentId: widget.documentId))).value
        : null;
    final existingLoan = user != null
        ? ref.watch(userDocActiveLoanProvider((userId: user.uid, documentId: widget.documentId))).value
        : null;

    return docAsync.when(
      loading: () => const Scaffold(
          backgroundColor: AppColors.bg,
          body: Center(child: CircularProgressIndicator(color: AppColors.accent))),
      error: (e, _) => Scaffold(
          backgroundColor: AppColors.bg,
          body: Center(child: Text('Erreur: $e', style: const TextStyle(color: AppColors.error)))),
      data: (doc) {
        if (doc == null) return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: Text('Document introuvable', style: TextStyle(color: AppColors.textMuted))));

        // Determine button state
        final bool hasActiveLoan = existingLoan != null;
        final bool hasReservation = existingReservation != null;
        final String? reservationStatus = existingReservation?.status;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COVER HERO
                SizedBox(
                  height: 280,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: doc.gradientColors),
                        ),
                      ),
                      Center(child: Text(doc.categoryEmoji, style: const TextStyle(fontSize: 90))),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 12, left: 16,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border)),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CHIPS ROW
                      Row(
                        children: [
                          _Chip(text: doc.categoryLabel, color: AppColors.accent, bg: AppColors.accentSoft),
                          const SizedBox(width: 8),
                          _Chip(
                            text: doc.isAvailable ? '${doc.availableCopies} disponible(s)' : 'Indisponible',
                            color: doc.isAvailable ? AppColors.success : AppColors.error,
                            bg: doc.isAvailable ? AppColors.successSoft : AppColors.errorSoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // TITLE
                      Text(doc.title, style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('${doc.author} · ${doc.year}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),

                      const SizedBox(height: 20),

                      // META GRID
                      Row(
                        children: [
                          Expanded(child: _MetaCard(emoji: '📚', value: '${doc.availableCopies}/${doc.totalCopies}', label: 'Exemplaires')),
                          const SizedBox(width: 10),
                          const Expanded(child: _MetaCard(emoji: '⏱', value: '21j', label: 'Durée max')),
                          const SizedBox(width: 10),
                          const Expanded(child: _MetaCard(emoji: '⭐', value: '—', label: 'Note moy.')),
                          const SizedBox(width: 10),
                          const Expanded(child: _MetaCard(emoji: '🔄', value: '—', label: 'Emprunts')),
                        ],
                      ),

                      // DESCRIPTION
                      if (doc.description.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('Description', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(doc.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                      ],

                      const SizedBox(height: 32),

                      // ── ACTION BUTTON (reactive to real-time status) ──
                      if (user != null) _buildActionButton(
                        doc: doc,
                        userId: user.uid,
                        hasActiveLoan: hasActiveLoan,
                        hasReservation: hasReservation,
                        reservationStatus: reservationStatus,
                      ),

                      const SizedBox(height: 12),
                      const Center(
                        child: Text('⭐ Priorité accordée aux apprenants logés',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required DocumentModel doc,
    required String userId,
    required bool hasActiveLoan,
    required bool hasReservation,
    required String? reservationStatus,
  }) {
    // Already borrowed
    if (hasActiveLoan) {
      return _StatusBanner(
        emoji: '📖',
        text: 'Vous avez déjà cet ouvrage en emprunt',
        color: AppColors.accent,
        bg: AppColors.accentSoft,
      );
    }

    // Already has reservation — show status
    if (hasReservation) {
      final (emoji, text, color, bg) = switch (reservationStatus) {
        'confirmed' => ('✅', 'Réservation confirmée — En attente de remise', AppColors.success, AppColors.successSoft),
        'waitlist' => ('📋', 'Vous êtes sur la liste d\'attente', AppColors.warning, AppColors.warningSoft),
        _ => ('⏳', 'Réservation en attente de validation', AppColors.warning, AppColors.warningSoft),
      };
      return _StatusBanner(emoji: emoji, text: text, color: color, bg: bg);
    }

    // Can reserve
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _reserving ? null : () => _reserve(doc, userId),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _reserving
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
                doc.availableCopies > 0 ? '📌 Réserver cet ouvrage' : '📋 Rejoindre la liste d\'attente',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;
  final Color bg;
  const _StatusBanner({required this.emoji, required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.35))),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Chip({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class _MetaCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _MetaCard({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      );
}
