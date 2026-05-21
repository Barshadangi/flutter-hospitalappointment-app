import 'package:flutter/material.dart';
import 'payment_success_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String slotId; // ✅ removed typo
  final String date;
  final String time;
  final String fee;
  final String patientName;
  final String patientAge;
  final String phone;
  final String address;
  final String problem;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.slotId,
    required this.date,
    required this.time,
    required this.fee,
    required this.patientName,
    required this.patientAge,
    required this.phone,
    required this.address,
    required this.problem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Confirm Payment"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.person,
                        size: 60, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Date: $date"),
                    Text("Time: $time"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    "Consultation Fee",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Rs. $fee",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {

                  final user =
                      FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  // ✅ 1️⃣ Save appointment
                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .add({
                    'userId': user.uid,
                    'doctorId': doctorId,
                    'doctorName': doctorName,
                    'slotId': slotId,
                    'date': date,
                    'time': time,
                    'fee': fee,
                    'patientName': patientName,
                    'patientAge': patientAge,
                    'phone': phone,
                    'address': address,
                    'problem': problem,
                    'status': 'pending',
                    'createdAt':
                        FieldValue.serverTimestamp(),
                  });

                  // ✅ 2️⃣ Mark slot as booked
                  await FirebaseFirestore.instance
                      .collection('time_slots')
                      .doc(slotId)
                      .update({
                    'isBooked': true,
                  });

                  // ✅ 3️⃣ Navigate
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PaymentSuccessScreen(
                        amount: int.parse(fee),
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Pay Now",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}