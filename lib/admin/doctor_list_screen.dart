import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_doctor_screen.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  void _showEditDialog(BuildContext context, DocumentSnapshot doc) {
    final nameController =
        TextEditingController(text: doc['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Doctor"),
          content: TextField(
            controller: nameController,
            decoration:
                const InputDecoration(labelText: "Doctor Name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0d6efd),
              ),
              child: const Text("Update"),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(doc.id)
                    .update({
                  'name': nameController.text.trim(),
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
        backgroundColor: const Color(0xff0d6efd),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0d6efd),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDoctorScreen(),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Doctors Found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final doctors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    doc['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Category: ${doc['categoryName']}"),
                      Text("Hospital: ${doc['hospitalName']}"),
                    ],
                  ),
                  onTap: () {
                    _showEditDialog(context, doc);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('doctors')
                          .doc(doc.id)
                          .delete();
                    },
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
