import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableSlotsScreen extends StatelessWidget {
  const AvailableSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Slots"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('time_slots')
            .where('isBooked', isEqualTo: false)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Available Slots"),
            );
          }

          final slots = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: slots.length,
            itemBuilder: (context, index) {

              final data =
                  slots[index].data()
                      as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.schedule,
                    color: Colors.green,
                  ),
                  title: Text(
                    data['doctorName'] ??
                        "Doctor",
                  ),
                  subtitle: Text(
                      "${data['date']} | ${data['time']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
