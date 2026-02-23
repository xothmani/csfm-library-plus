import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_model.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/notifications/notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    final notifsAsync = ref.watch(notificationsProvider(user.uid));
    final notifs = notifsAsync.value ?? [];
    final unread = notifs.where((n) => !n.isRead).toList();

    // Group by date
    final today = <NotificationModel>[];
    final week = <NotificationModel>[];
    final older = <NotificationModel>[];
    final now = DateTime.now();
    for (final n in notifs) {
      final diff = now.difference(n.createdAt);
      if (diff.inDays == 0) {
        today.add(n);
      } else if (diff.inDays <= 7) {
        week.add(n);
      } else {
        older.add(n);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                        if (unread.isNotEmpty)
                          Text('${unread.length} non lue(s)', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (unread.isNotEmpty)
                    GestureDetector(
                      onTap: () => markAllNotificationsRead(unread),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Tout lire', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),

            // LIST
            Expanded(
              child: notifs.isEmpty
                  ? const EmptyState(emoji: '🔔', title: 'Aucune notification', subtitle: 'Vous serez alerté des retours et disponibilités ici')
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        if (today.isNotEmpty) ...[
                          _Section(title: 'Aujourd\'hui'),
                          ...today.map((n) => NotificationItem(notification: n)),
                        ],
                        if (week.isNotEmpty) ...[
                          _Section(title: 'Cette semaine'),
                          ...week.map((n) => NotificationItem(notification: n)),
                        ],
                        if (older.isNotEmpty) ...[
                          _Section(title: 'Plus ancien'),
                          ...older.map((n) => NotificationItem(notification: n)),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      );
}
