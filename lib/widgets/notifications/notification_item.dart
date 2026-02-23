import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/notifications_provider.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  Color get _iconBg {
    switch (notification.type) {
      case 'reminder': return AppColors.warningSoft;
      case 'overdue': return AppColors.errorSoft;
      case 'availability': return AppColors.successSoft;
      case 'confirmation': return AppColors.accentSoft;
      default: return AppColors.surfaceElevated;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'reminder': return AppColors.warning;
      case 'overdue': return AppColors.error;
      case 'availability': return AppColors.success;
      case 'confirmation': return AppColors.accent;
      default: return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays}j';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return GestureDetector(
      onTap: () => markNotificationRead(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppColors.accentSoft.withValues(alpha: 0.3) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: unread ? AppColors.accent : Colors.transparent, width: 3),
            top: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: _iconBg, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(notification.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(notification.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(_timeAgo(notification.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            // Unread dot
            if (unread)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 4, left: 8),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
