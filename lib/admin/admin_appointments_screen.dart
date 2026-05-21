import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  Future<void> _updateStatus(
      String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(docId)
        .update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Appointments"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No Appointments Found"));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {

              final appointment = appointments[index];
              final docId = appointment.id;

              final data =
                  appointment.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // ✅ Patient Name (from appointment)
                      Text(
                        data['patientName'] ?? "No Name",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("Phone: ${data['phone'] ?? ''}"),
                      Text("Address: ${data['address'] ?? ''}"),
                      Text("Age: ${data['patientAge'] ?? ''}"),

                      const Divider(height: 20),

                      Text(
                        "Doctor: ${data['doctorName'] ?? ''}",
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text("Date: ${data['date'] ?? ''}"),
                      Text("Time: ${data['time'] ?? ''}"),

                      const SizedBox(height: 6),

                      Text(
                        "Status: ${data['status'] ?? ''}",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              data['status'] ==
                                      "approved"
                                  ? Colors.green
                                  : data['status'] ==
                                          "rejected"
                                      ? Colors.red
                                      : Colors
                                          .orange,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (data['status'] == "pending")
                        Row(
                          children: [

                            Expanded(
                              child: ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green,
                                ),
                                onPressed: () {
                                  _updateStatus(
                                      docId,
                                      "approved");
                                },
                                child:
                                    const Text("Approve"),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                ),
                                onPressed: () {
                                  _updateStatus(
                                      docId,
                                      "rejected");
                                },
                                child:
                                    const Text("Reject"),
                              ),
                            ),
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