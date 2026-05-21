import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  void _showEditDialog(
      BuildContext context, String docId, String oldName) {
    final TextEditingController controller =
        TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Category"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Category Name",
              border: OutlineInputBorder(),
            ),
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
                if (controller.text.trim().isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('categories')
                    .doc(docId)
                    .update({
                  'name': controller.text.trim(),
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
    final currentEmail =
        FirebaseAuth.instance.currentUser!.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: const Color(0xff0d6efd),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('adminEmail', isEqualTo: currentEmail)
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
                "No Categories Found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final doc = categories[index];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(
                    doc['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),

                  // 🔥 Edit when tapped
                  onTap: () {
                    _showEditDialog(
                        context, doc.id, doc['name']);
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('categories')
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
