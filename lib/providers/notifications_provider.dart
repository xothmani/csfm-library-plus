import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

// All notifications stream
final notificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => NotificationModel.fromMap(d.data(), d.id))
          .toList());
});

// Unread count provider
final unreadCountProvider = Provider.family<int, String>((ref, userId) {
  final notifs = ref.watch(notificationsProvider(userId));
  return notifs.value?.where((n) => !n.isRead).length ?? 0;
});

// Mark single notification as read
Future<void> markNotificationRead(String notifId) async {
  await FirebaseFirestore.instance
      .collection('notifications')
      .doc(notifId)
      .update({'isRead': true});
}

// Mark all notifications as read
Future<void> markAllNotificationsRead(List<NotificationModel> unread) async {
  final batch = FirebaseFirestore.instance.batch();
  for (final n in unread) {
    batch.update(
      FirebaseFirestore.instance.collection('notifications').doc(n.id),
      {'isRead': true},
    );
  }
  await batch.commit();
}
