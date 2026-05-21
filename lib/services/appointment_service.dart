import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create appointment with payment pending
  Future<String> createAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    required int amount,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    DocumentReference docRef =
        await _firestore.collection('appointments').add({
      'doctorId': doctorId,
      'userId': user.uid,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'status': 'payment_pending',
      'paymentStatus': 'pending',
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Confirm payment
  Future<void> confirmPayment(String appointmentId) async {
    String transactionId =
        "TXN${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}";

    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'confirmed',
      'paymentStatus': 'paid',
      'transactionId': transactionId,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark payment failed
  Future<void> markPaymentFailed(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'cancelled',
      'paymentStatus': 'failed',
    });
  }
}
