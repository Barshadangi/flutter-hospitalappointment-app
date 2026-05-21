import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: currentUser.uid)
            // 🔥 Add orderBy later after index is enabled
            // .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final appointments = snapshot.data?.docs ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                "No Appointments Yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final data =
                  appointment.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['doctorName'] ?? 'Doctor',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                              "Date: ${data['date'] ?? ''}"),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                              "Time: ${data['time'] ?? ''}"),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                              "Patient: ${data['patientName'] ?? ''}"),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                              "Status: ${data['status'] ?? 'Booked'}"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}