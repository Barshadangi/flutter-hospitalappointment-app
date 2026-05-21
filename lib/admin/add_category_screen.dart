import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController categoryController = TextEditingController();
  bool isLoading = false;

  Future<void> addCategory() async {
    if (categoryController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('categories').add({
      'name': categoryController.text.trim(),
      'adminEmail': FirebaseAuth.instance.currentUser!.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category"),
        backgroundColor: const Color(0xff0d6efd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: "Category Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0d6efd),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: isLoading ? null : addCategory,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
