import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../models/reservation_model.dart';

// Active loans (active + overdue) — no orderBy to avoid composite index
final activeLoansProvider =
    StreamProvider.family<List<LoanModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('loans')
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: ['active', 'overdue'])
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList();
        list.sort((a, b) => (b.borrowedAt ?? DateTime(0)).compareTo(a.borrowedAt ?? DateTime(0)));
        return list;
      });
});

// Loan history (returned) — single where, orderBy is safe here
final loanHistoryProvider =
    StreamProvider.family<List<LoanModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('loans')
      .where('userId', isEqualTo: userId)
      .where('status', isEqualTo: 'returned')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList();
        list.sort((a, b) => (b.returnedAt ?? DateTime(0)).compareTo(a.returnedAt ?? DateTime(0)));
        return list;
      });
});

// ── CHECK IF USER ALREADY HAS A RESERVATION/LOAN FOR A SPECIFIC DOCUMENT ───
// Returns the reservation model if exists, null otherwise
final userDocReservationProvider = StreamProvider.family<ReservationModel?,
    ({String userId, String documentId})>((ref, args) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .where('userId', isEqualTo: args.userId)
      .where('documentId', isEqualTo: args.documentId)
      .where('status', whereIn: ['pending', 'waitlist', 'confirmed'])
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty
          ? null
          : ReservationModel.fromMap(s.docs.first.data(), s.docs.first.id));
});

// Returns the active loan if user already borrowed this document
final userDocActiveLoanProvider = StreamProvider.family<LoanModel?,
    ({String userId, String documentId})>((ref, args) {
  return FirebaseFirestore.instance
      .collection('loans')
      .where('userId', isEqualTo: args.userId)
      .where('documentId', isEqualTo: args.documentId)
      .where('status', whereIn: ['active', 'overdue'])
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isEmpty
          ? null
          : LoanModel.fromMap(s.docs.first.data(), s.docs.first.id));
});
