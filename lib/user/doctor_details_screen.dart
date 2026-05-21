import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<DoctorDetailsScreen> createState() =>
      _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {

  String? selectedSlotId;
  String? selectedDate;
  String? selectedTime;
  String doctorFee = "";

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final problemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctorFee();
  }

  Future<void> fetchDoctorFee() async {
    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();

    if (doc.exists && doc.data()!.containsKey('fee')) {
      setState(() {
        doctorFee = doc['fee'].toString();
      });
    }
  }

  void proceedToPayment() {

    if (selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot")),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all patient details")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          slotId: selectedSlotId!,
          date: selectedDate!,
          time: selectedTime!,
          fee: doctorFee,
          patientName: nameController.text.trim(),
          patientAge: ageController.text.trim(),
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          problem: problemController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctorName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('time_slots')
            .where('doctorId', isEqualTo: widget.doctorId)
            .where('isBooked', isEqualTo: false)
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
                "No Appointment Available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final slots = snapshot.data!.docs;

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Text(
                      doctorFee.isEmpty
                          ? "Loading fee..."
                          : "Consultation Fee: Rs. $doctorFee",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Patient Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: problemController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Describe Problem",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {

                    final data =
                        slots[index].data()
                            as Map<String, dynamic>;

                    final slotId = slots[index].id;

                    return ListTile(
                      title: Text(data['date']),
                      subtitle: Text(data['time']),
                      tileColor:
                          selectedSlotId == slotId
                              ? Colors.blue.shade100
                              : null,
                      onTap: () {
                        setState(() {
                          selectedSlotId = slotId;
                          selectedDate = data['date'];
                          selectedTime = data['time'];
                        });
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: proceedToPayment,
                    child: const Text("Book Appointment"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
