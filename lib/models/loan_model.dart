import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String id;
  final String userId;
  final String documentId;
  final String status; // 'reserved' | 'active' | 'returned' | 'overdue'
  final DateTime? borrowedAt;
  final DateTime? dueDate;
  final DateTime? returnedAt;

  LoanModel({
    required this.id,
    required this.userId,
    required this.documentId,
    required this.status,
    this.borrowedAt,
    this.dueDate,
    this.returnedAt,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map, String docId) {
    return LoanModel(
      id: docId,
      userId: map['userId'] ?? '',
      documentId: map['documentId'] ?? '',
      status: map['status'] ?? 'reserved',
      borrowedAt: (map['borrowedAt'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      returnedAt: (map['returnedAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status == 'active';
  }

  double get progressValue {
    if (borrowedAt == null || dueDate == null) return 0;
    final total = dueDate!.difference(borrowedAt!).inDays;
    if (total == 0) return 1;
    final elapsed = DateTime.now().difference(borrowedAt!).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  int get daysRemaining {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }
}
