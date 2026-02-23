import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../models/loan_model.dart';
import '../../models/document_model.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final DocumentModel document;

  const LoanCard({super.key, required this.loan, required this.document});

  @override
  Widget build(BuildContext context) {
    final overdue = loan.isOverdue || loan.status == 'overdue';
    final progress = loan.progressValue;
    final days = loan.daysRemaining;

    return GestureDetector(
      onTap: () => context.push('/catalogue/document/${document.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: overdue ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Book cover
                Container(
                  width: 54, height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: document.gradientColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(document.categoryEmoji, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(document.author, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 8),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: overdue ? AppColors.errorSoft : AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          overdue ? '⚠ En retard' : '✓ En cours',
                          style: TextStyle(color: overdue ? AppColors.error : AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                // Due date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Retour', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      loan.dueDate != null ? _formatDate(loan.dueDate!) : '—',
                      style: TextStyle(color: overdue ? AppColors.error : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress, minHeight: 5,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(overdue ? AppColors.error : AppColors.success),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(overdue ? '${(-days).abs()}j de retard' : '${days}j restants', style: TextStyle(color: overdue ? AppColors.error : AppColors.textMuted, fontSize: 11)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class HistoryLoanItem extends StatelessWidget {
  final LoanModel loan;
  final DocumentModel document;

  const HistoryLoanItem({super.key, required this.loan, required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: document.gradientColors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(document.categoryEmoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(
                  loan.returnedAt != null ? '✓ Retourné le ${_fmt(loan.returnedAt!)}' : '✓ Retourné',
                  style: const TextStyle(color: AppColors.success, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(8)),
            child: const Text('Rendu', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class OverdueAlertBanner extends StatelessWidget {
  const OverdueAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Text('🚨', style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Retard détecté — Veuillez retourner le document dès que possible',
              style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
