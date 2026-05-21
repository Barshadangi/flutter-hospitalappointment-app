import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final currentUser =
        FirebaseAuth.instance.currentUser;

    final today =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId',
                isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final allAppointments =
              snapshot.data!.docs;

          // 🔴 FILTER ONLY PAST DATES
          final historyAppointments =
              allAppointments.where((doc) {
            final data =
                doc.data() as Map<String, dynamic>;

            return data['date'] != null &&
                data['date'].compareTo(today) < 0;
          }).toList();

          if (historyAppointments.isEmpty) {
            return const Center(
              child: Text("No History Yet"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                historyAppointments.length,
            itemBuilder: (context, index) {

              final data =
                  historyAppointments[index]
                      .data() as Map<String, dynamic>;

              return Container(
                margin:
                    const EdgeInsets.only(
                        bottom: 16),
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      data['doctorName'] ?? '',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        "Date: ${data['date']}"),
                    Text(
                        "Time: ${data['time']}"),
                    const Text(
                      "Status: Completed",
                      style: TextStyle(
                          color: Colors.green),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
