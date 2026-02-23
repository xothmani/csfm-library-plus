import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'reminder' | 'overdue' | 'availability' | 'confirmation' | 'info'
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data; // extra data e.g. documentId

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'info',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }

  String get emoji {
    switch (type) {
      case 'reminder': return '⏰';
      case 'overdue': return '🚨';
      case 'availability': return '✅';
      case 'confirmation': return '📚';
      default: return '🔔';
    }
  }
}
