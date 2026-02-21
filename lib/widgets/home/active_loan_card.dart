import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../models/loan_model.dart';

class ActiveLoanCard extends StatelessWidget {
  final LoanModel loan;
  final DocumentModel document;

  const ActiveLoanCard({super.key, required this.loan, required this.document});

  @override
  Widget build(BuildContext context) {
    final overdue = loan.isOverdue;
    final progress = loan.progressValue;
    final days = loan.daysRemaining;

    return GestureDetector(
      onTap: () => context.push('/document/${document.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: document.gradientColors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(document.categoryEmoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(document.author, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress, minHeight: 4,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(overdue ? AppColors.error : AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    overdue ? 'En retard de ${-days}j' : 'Retour dans ${days}j',
                    style: TextStyle(color: overdue ? AppColors.error : AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
