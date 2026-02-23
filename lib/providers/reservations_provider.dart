import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation_model.dart';

// Active reservations (pending, confirmed, waitlist)
final activeReservationsProvider =
    StreamProvider.family<List<ReservationModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: ['pending', 'confirmed', 'waitlist'])
      .orderBy('requestedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ReservationModel.fromMap(d.data(), d.id))
          .toList());
});

// Past reservations (cancelled, expired)
final pastReservationsProvider =
    StreamProvider.family<List<ReservationModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: ['cancelled', 'expired'])
      .orderBy('requestedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => ReservationModel.fromMap(d.data(), d.id))
          .toList());
});

// Cancel a reservation
Future<void> cancelReservation(String reservationId) async {
  await FirebaseFirestore.instance
      .collection('reservations')
      .doc(reservationId)
      .update({'status': 'cancelled'});
}
