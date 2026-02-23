import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../models/loan_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import 'documents_provider.dart'; // re-use existing documentsProvider stream

// ── KPI MODEL ────────────────────────────────────────────────────────────────
class AdminStats {
  final int totalDocs;
  final int activeLoans;
  final int overdueLoans;
  final int totalUsers;
  const AdminStats({
    required this.totalDocs,
    required this.activeLoans,
    required this.overdueLoans,
    required this.totalUsers,
  });
  factory AdminStats.empty() =>
      const AdminStats(totalDocs: 0, activeLoans: 0, overdueLoans: 0, totalUsers: 0);
}

// ── LIVE STREAM PROVIDERS (reactive — update instantly on Firestore change) ──

// All active loans (active + overdue)
final allActiveLoansAdminProvider = StreamProvider<List<LoanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('loans')
      .where('status', whereIn: ['active', 'overdue'])
      .snapshots()
      .map((s) {
        final list = s.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList();
        list.sort((a, b) => (b.borrowedAt ?? DateTime(0)).compareTo(a.borrowedAt ?? DateTime(0)));
        return list;
      });
});

// Overdue loans only
final overdueLoansAdminProvider = StreamProvider<List<LoanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('loans')
      .where('status', isEqualTo: 'overdue')
      .snapshots()
      .map((s) => s.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList());
});

// ALL loans stream (for weekly chart computation)
final _allLoansStreamProvider = StreamProvider<List<LoanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('loans')
      .snapshots()
      .map((s) => s.docs.map((d) => LoanModel.fromMap(d.data(), d.id)).toList());
});

// All users
final allUsersAdminProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
});

// Pending reservations (for admin to validate)
final pendingReservationsAdminProvider = StreamProvider<List<ReservationModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .where('status', whereIn: ['pending', 'waitlist'])
      .snapshots()
      .map((s) {
        final list = s.docs.map((d) => ReservationModel.fromMap(d.data(), d.id)).toList();
        // Sort oldest first (no orderBy = no composite index needed)
        list.sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
        return list;
      });
});

// ── DERIVED PROVIDERS (auto-update when streams change) ──────────────────────

/// KPI dashboard stats — derived from live streams, updates instantly
final adminStatsProvider = Provider<AdminStats>((ref) {
  final docs = ref.watch(documentsProvider).value?.length ?? 0;
  final active = ref.watch(allActiveLoansAdminProvider).value?.length ?? 0;
  final overdue = ref.watch(overdueLoansAdminProvider).value?.length ?? 0;
  final users = ref.watch(allUsersAdminProvider).value?.length ?? 0;
  return AdminStats(
    totalDocs: docs,
    activeLoans: active,
    overdueLoans: overdue,
    totalUsers: users,
  );
});

/// Weekly loans bar chart — derives counts from the live all-loans stream
final weeklyLoansProvider = Provider<List<int>>((ref) {
  final allLoans = ref.watch(_allLoansStreamProvider).value ?? [];
  final now = DateTime.now();
  return List.generate(7, (i) {
    final day = now.subtract(Duration(days: 6 - i));
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return allLoans.where((l) {
      if (l.borrowedAt == null) return false;
      return l.borrowedAt!.isAfter(start) && l.borrowedAt!.isBefore(end);
    }).length;
  });
});

// ── SEARCH NOTIFIERS ─────────────────────────────────────────────────────────
class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final adminDocSearchProvider =
    NotifierProvider<_SearchNotifier, String>(_SearchNotifier.new);
final adminUserSearchProvider =
    NotifierProvider<_SearchNotifier, String>(_SearchNotifier.new);

// ── OPERATIONS (batch writes) ─────────────────────────────────────────────────

Future<void> validateLoan({
  required String reservationId,
  required String userId,
  required String documentId,
  required String validatedBy,
}) async {
  final batch = FirebaseFirestore.instance.batch();
  batch.update(
    FirebaseFirestore.instance.collection('reservations').doc(reservationId),
    {'status': 'confirmed'},
  );
  final loanRef = FirebaseFirestore.instance.collection('loans').doc();
  batch.set(loanRef, {
    'userId': userId,
    'documentId': documentId,
    'status': 'active',
    'validatedBy': validatedBy,
    'borrowedAt': FieldValue.serverTimestamp(),
    'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 21))),
    'returnedAt': null,
    'reminderSent': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
  batch.update(
    FirebaseFirestore.instance.collection('documents').doc(documentId),
    {'availableCopies': FieldValue.increment(-1)},
  );
  await batch.commit();
}

Future<void> returnBook({
  required String loanId,
  required String documentId,
}) async {
  final batch = FirebaseFirestore.instance.batch();
  batch.update(
    FirebaseFirestore.instance.collection('loans').doc(loanId),
    {'status': 'returned', 'returnedAt': FieldValue.serverTimestamp()},
  );
  batch.update(
    FirebaseFirestore.instance.collection('documents').doc(documentId),
    {'availableCopies': FieldValue.increment(1), 'isAvailable': true},
  );
  await batch.commit();
}

Future<void> addDocument(Map<String, dynamic> data) async {
  final copies = (data['totalCopies'] as int?) ?? 1;
  await FirebaseFirestore.instance.collection('documents').add({
    ...data,
    'availableCopies': copies,
    'isAvailable': copies > 0,
    'coverUrl': '',
    'tags': [],
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> updateDocument(String docId, Map<String, dynamic> data) async {
  final copies = (data['totalCopies'] as int?) ?? 1;
  await FirebaseFirestore.instance.collection('documents').doc(docId).update({
    ...data,
    'isAvailable': copies > 0,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> deleteDocument(String docId) async {
  await FirebaseFirestore.instance.collection('documents').doc(docId).delete();
}
