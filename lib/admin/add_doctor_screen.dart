import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {

  final nameController = TextEditingController();
  final hospitalController = TextEditingController();
  final cityController = TextEditingController();
  final specializationController = TextEditingController();
  final feeController = TextEditingController();

  String? selectedCategory;

  // 🔥 NEW: category list from Firestore
  List<QueryDocumentSnapshot> categoryList = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // 🔥 FETCH categories from Firestore
  Future<void> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    setState(() {
      categoryList = snapshot.docs;
    });
  }

  Future<void> addDoctor() async {

    if (nameController.text.trim().isEmpty ||
        hospitalController.text.trim().isEmpty ||
         cityController.text.trim().isEmpty ||
        specializationController.text.trim().isEmpty ||
        feeController.text.trim().isEmpty ||
        selectedCategory == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {

      int fee = int.parse(feeController.text.trim());

     await FirebaseFirestore.instance.collection('doctors').add({

  "name": nameController.text.trim(),
  "categoryName": selectedCategory,
  "hospitalName": hospitalController.text.trim(),

  "category": selectedCategory,
  "city": cityController.text.trim(),
  "specialization": specializationController.text.trim(),

  "fee": fee,
  "createdAt": FieldValue.serverTimestamp(),
});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doctor Added Successfully")),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Doctor"),
        backgroundColor: const Color(0xff0d6efd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Doctor Name",
                ),
              ),

              const SizedBox(height: 15),
TextField(
  controller: hospitalController,
  decoration: const InputDecoration(
    labelText: "Hospital Name",
  ),
),

const SizedBox(height: 15),

TextField(
  controller: cityController,
  decoration: const InputDecoration(
    labelText: "City",
  ),
),

              const SizedBox(height: 15),

              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: "Specialization",
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Consultation Fee",
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 FIXED CATEGORY DROPDOWN (Now connected to Firestore)
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: const Text("Select Category"),
                items: categoryList.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc['name'], // store category name
                    child: Text(doc['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0d6efd),
                  ),
                  onPressed: addDoctor,
                  child: const Text(
                    "Add Doctor",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
