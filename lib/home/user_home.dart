// (ALL YOUR IMPORTS SAME)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user/my_appointments_screen.dart';
import '../user/user_profile_screen.dart';
import '../user/doctor_details_screen.dart';
import '../user/history_screen.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;

  String? selectedDepartment;
  String searchLocation = "";

  final ScrollController _departmentScrollController =
      ScrollController();

  @override
  void dispose() {
    _departmentScrollController.dispose();
    super.dispose();
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  IconData getIconForDepartment(String name) {
    final lower = name.toLowerCase();

    if (lower.contains("cardio")) {
      return Icons.favorite;
    } else if (lower.contains("neuro")) {
      return Icons.psychology;
    } else if (lower.contains("eye") || lower.contains("ophthal")) {
      return Icons.visibility;
    } else if (lower.contains("dental")) {
      return Icons.medical_services;
    } else if (lower.contains("pediatric") || lower.contains("child")) {
      return Icons.child_care;
    } else if (lower.contains("ortho")) {
      return Icons.accessibility_new;
    } else if (lower.contains("derma") || lower.contains("skin")) {
      return Icons.spa;
    } else if (lower.contains("physician") || lower.contains("general")) {
      return Icons.medical_services;
    } else if (lower.contains("pulmo") || lower.contains("lung")) {
      return Icons.air;
    } else if (lower.contains("hema") || lower.contains("blood")) {
      return Icons.bloodtype;
    } else if (lower.contains("ent") ||
        lower.contains("ear") ||
        lower.contains("nose") ||
        lower.contains("throat")) {
      return Icons.hearing;
    } else {
      return Icons.local_hospital;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("SewaBook"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 1
              ? const MyAppointmentsScreen()
              : const UserProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2F80ED),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [

        // 🔍 LOCATION SEARCH
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchLocation = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search Location...",
              prefixIcon: const Icon(Icons.location_on),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 🏥 DYNAMIC DEPARTMENT SECTION WITH < >
        SizedBox(
          height: 120,
          child: Row(
            children: [

              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  _departmentScrollController.animateTo(
                    _departmentScrollController.offset - 120,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data!.docs;

                    return ListView.builder(
                      controller: _departmentScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {

                        final data = categories[index].data()
                            as Map<String, dynamic>;

                        final categoryName = data['name'];

                        final isSelected =
                            selectedDepartment == categoryName;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDepartment =
                                  selectedDepartment == categoryName
                                      ? null
                                      : categoryName;
                            });
                          },
                          child: Container(
                            width: 100,
                            margin:
                                const EdgeInsets.only(right: 12),
                            padding:
                                const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2F80ED)
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  getIconForDepartment(
                                      categoryName),
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  categoryName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  _departmentScrollController.animateTo(
                    _departmentScrollController.offset + 120,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 👨‍⚕️ DOCTOR LIST (UNCHANGED)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              var doctors = snapshot.data!.docs;

              doctors = doctors.where((doc) {
                final data =
                    doc.data() as Map<String, dynamic>;

                final matchesDepartment =
                    selectedDepartment == null ||
                        data['specialization'] ==
                            selectedDepartment;
final matchesLocation = searchLocation.isEmpty ||
    (data['city'] ?? '')
        .toLowerCase()
        .contains(searchLocation) ||
    (data['hospitalName'] ?? '')
        .toLowerCase()
        .contains(searchLocation);
                return matchesDepartment &&
                    matchesLocation;
              }).toList();

              if (doctors.isEmpty) {
                return const Center(
                  child: Text("No doctors found"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {

                  var doctor = doctors[index];
                  final data =
                      doctor.data() as Map<String, dynamic>;

                  return Container(
                    margin:
                        const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          data['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text("Specialization: ${data['specialization'] ?? ''}"),
                        Text("City: ${data['city'] ?? ''}"),
                        Text("Fee: Rs. ${data['fee'] ?? 0}"),
                        Text("Hospital Name: ${data['hospitalName'] ?? ''}"),


                        const SizedBox(height: 12),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('time_slots')
                              .where('doctorId',
                                  isEqualTo: doctor.id)
                              .where('isBooked',
                                  isEqualTo: false)
                              .snapshots(),
                          builder: (context, slotSnapshot) {

                            if (!slotSnapshot.hasData) {
                              return const SizedBox(
                                height: 45,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(
                                          strokeWidth: 2),
                                ),
                              );
                            }

                            final availableSlots =
                                slotSnapshot.data!.docs;

                            if (availableSlots.isEmpty) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: null,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.grey,
                                  ),
                                  child: const Text(
                                    "No Slots Available",
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DoctorDetailsScreen(
                                        doctorId: doctor.id,
                                        doctorName:
                                            data['name'] ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Book Appointment",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}