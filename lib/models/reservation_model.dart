import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final String documentId;
  final String status; // 'pending' | 'confirmed' | 'waitlist' | 'cancelled'
  final DateTime requestedAt;
  final DateTime? expiresAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.documentId,
    required this.status,
    required this.requestedAt,
    this.expiresAt,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReservationModel(
      id: docId,
      userId: map['userId'] ?? '',
      documentId: map['documentId'] ?? '',
      status: map['status'] ?? 'pending',
      requestedAt: (map['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
    );
  }
}

class UserStats {
  final int activeLoans;
  final int pendingReservations;
  final int returnedLoans;

  const UserStats({
    required this.activeLoans,
    required this.pendingReservations,
    required this.returnedLoans,
  });

  factory UserStats.empty() => const UserStats(
        activeLoans: 0,
        pendingReservations: 0,
        returnedLoans: 0,
      );
}
