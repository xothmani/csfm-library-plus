import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../models/reservation_model.dart';

// User loans stream by userId
final userLoansProvider =
    StreamProvider.family<List<LoanModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('loans')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList());
});

// User stats (counts)
final userStatsProvider =
    FutureProvider.family<UserStats, String>((ref, userId) async {
  final loansSnap = await FirebaseFirestore.instance
      .collection('loans')
      .where('userId', isEqualTo: userId)
      .get();

  final resSnap = await FirebaseFirestore.instance
      .collection('reservations')
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: ['pending', 'confirmed'])
      .get();

  final loans =
      loansSnap.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList();

  return UserStats(
    activeLoans: loans.where((l) => l.status == 'active').length,
    pendingReservations: resSnap.docs.length,
    returnedLoans: loans.where((l) => l.status == 'returned').length,
  );
});

// Create a reservation
Future<void> createReservation({
  required String userId,
  required String documentId,
  required int availableCopies,
}) async {
  final status = availableCopies > 0 ? 'pending' : 'waitlist';
  await FirebaseFirestore.instance.collection('reservations').add({
    'userId': userId,
    'documentId': documentId,
    'status': status,
    'requestedAt': FieldValue.serverTimestamp(),
    'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
  });
}
