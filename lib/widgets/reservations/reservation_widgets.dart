import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../providers/reservations_provider.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final String bookTitle;
  final String bookAuthor;
  final String bookEmoji;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookEmoji,
  });

  Color get _statusColor {
    switch (reservation.status) {
      case 'confirmed': return AppColors.accent;
      case 'pending': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  Color get _statusBg {
    switch (reservation.status) {
      case 'confirmed': return AppColors.accentSoft;
      case 'pending': return AppColors.warningSoft;
      default: return AppColors.surfaceElevated;
    }
  }

  String get _statusLabel {
    switch (reservation.status) {
      case 'confirmed': return '✓ Confirmée';
      case 'pending': return '⏳ En attente';
      case 'waitlist': return '📋 Liste d\'attente';
      default: return reservation.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Top: book info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52, height: 66,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(child: Text(bookEmoji, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bookTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(bookAuthor, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(8)),
                        child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: AppColors.border),
          // Bottom: expiry + actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (reservation.expiresAt != null)
                  Text(
                    'Expire le ${_fmt(reservation.expiresAt!)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                const Spacer(),
                // Cancel button
                GestureDetector(
                  onTap: () => _confirmCancel(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Annuler', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _confirmCancel(BuildContext context) {
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
            const Text('❌', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text('Annuler la réservation ?', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('"$bookTitle" sera remis en disponibilité.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('Garder', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await cancelReservation(reservation.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
                      child: const Center(child: Text('Annuler', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
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

class PastReservationItem extends StatelessWidget {
  final ReservationModel reservation;
  final String bookTitle;
  final String bookEmoji;

  const PastReservationItem({super.key, required this.reservation, required this.bookTitle, required this.bookEmoji});

  @override
  Widget build(BuildContext context) {
    final isCancelled = reservation.status == 'cancelled';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(bookEmoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bookTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  isCancelled ? '❌ Annulée · ${_fmt(reservation.requestedAt)}' : '⏰ Expirée · ${_fmt(reservation.requestedAt)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
