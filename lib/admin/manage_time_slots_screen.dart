import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTimeSlotsScreen extends StatefulWidget {
  const ManageTimeSlotsScreen({super.key});

  @override
  State<ManageTimeSlotsScreen> createState() =>
      _ManageTimeSlotsScreenState();
}

class _ManageTimeSlotsScreenState
    extends State<ManageTimeSlotsScreen> {

  String? selectedDoctorId;
  String? selectedDoctorName;

  final TextEditingController dateController =
      TextEditingController();
  final TextEditingController timeController =
      TextEditingController();

  // 🔥 ADD TIME SLOT
  Future<void> addTimeSlot() async {
    if (selectedDoctorId == null ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('time_slots')
        .add({
      'doctorId': selectedDoctorId,
      'doctorName': selectedDoctorName,
      'date': dateController.text,
      'time': timeController.text,
      'isBooked': false,
      'createdAt': Timestamp.now(),
    });

    dateController.clear();
    timeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Time slot added"),
      ),
    );
  }

  // 🔥 DELETE SLOT
  Future<void> deleteSlot(String docId) async {
    await FirebaseFirestore.instance
        .collection('time_slots')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Time Slots"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ===== DOCTOR DROPDOWN =====
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final doctors = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Doctor",
                    border: OutlineInputBorder(),
                  ),
                  items: doctors.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['name'] ?? "No Name"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedDoctorId = value;
                    selectedDoctorName = doctors
                        .firstWhere(
                            (doc) => doc.id == value)['name'];
                  },
                );
              },
            ),

            const SizedBox(height: 15),

            // ===== DATE FIELD =====
           TextField(
  controller: dateController,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: "Select Date",
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.calendar_today),
  ),
  onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      setState(() {
        dateController.text = formattedDate;
      });
    }
  },
),

            const SizedBox(height: 15),

            // ===== TIME FIELD =====
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Time (e.g. 10:00 AM)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ===== ADD BUTTON =====
            ElevatedButton(
              onPressed: addTimeSlot,
              child: const Text("Add Time Slot"),
            ),

            const SizedBox(height: 25),

            const Divider(),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Existing Time Slots",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ===== SLOT LIST =====
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('time_slots')
                    .orderBy('createdAt',
                        descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No Slots Added"));
                  }

                  final slots = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: slots.length,
                    itemBuilder: (context, index) {

                      final data =
                          slots[index].data()
                              as Map<String, dynamic>;
                      final docId = slots[index].id;

                      return Card(
                        child: ListTile(
                          title: Text(
                              "${data['doctorName']}"),
                          subtitle: Text(
                              "${data['date']}  |  ${data['time']}"),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                deleteSlot(docId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
