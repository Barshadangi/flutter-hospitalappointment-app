import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/add_category_screen.dart';
import '../admin/admin_appointments_screen.dart';
import '../admin/profile_screen.dart';
import '../admin/doctor_list_screen.dart';
import '../admin/category_list_screen.dart';
import '../admin/manage_time_slots_screen.dart';
import '../admin/available_slots_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    DateTime today = DateTime.now();
    String todayString =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [

            // ===== HEADER =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0d6efd), Color(0xff0dcaf0)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Good Morning 👋\nAdmin",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? "",
                    style:
                        const TextStyle(color: Colors.white70),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== STATS =====
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .snapshots(),
                builder: (context, appointmentSnapshot) {

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .where('adminEmail',
                            isEqualTo: user?.email)
                        .snapshots(),
                    builder: (context, categorySnapshot) {

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('time_slots')
                            .where('isBooked',
                                isEqualTo: false)
                            .where('date',
                                isEqualTo: todayString)
                            .snapshots(),
                        builder: (context, slotSnapshot) {

                          int total = 0;
                          int todayAppointments = 0;
                          int availableSlots = 0;
                          int categories = 0;

                          if (appointmentSnapshot.hasData) {
                            total = appointmentSnapshot
                                .data!.docs.length;

                            todayAppointments =
                                appointmentSnapshot
                                    .data!.docs
                                    .where((e) =>
                                        e['date'] ==
                                        todayString)
                                    .length;
                          }

                          if (categorySnapshot.hasData) {
                            categories =
                                categorySnapshot
                                    .data!.docs.length;
                          }

                          if (slotSnapshot.hasData) {
                            availableSlots =
                                slotSnapshot
                                    .data!.docs.length;
                          }

                          return SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 20),
                            child: Column(
                              children: [

                                /// ROW 1
                                Row(
                                  children: [

                                    // TOTAL
                                    buildStatCard(
                                      context,
                                      "Total Appointments",
                                      total,
                                      Icons.calendar_today,
                                      Colors.blue,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminAppointmentsScreen(),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 15),

                                    // TODAY
                                    buildStatCard(
                                      context,
                                      "Today",
                                      todayAppointments,
                                      Icons.today,
                                      Colors.orange,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminAppointmentsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                /// ROW 2
                                Row(
                                  children: [

                                    // ✅ AVAILABLE SLOTS (NOW OPENS AvailableSlotsScreen)
                                    buildStatCard(
                                      context,
                                      "Available Slots",
                                      availableSlots,
                                      Icons.schedule,
                                      Colors.green,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AvailableSlotsScreen(),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 15),

                                    // CATEGORIES
                                    buildStatCard(
                                      context,
                                      "Categories",
                                      categories,
                                      Icons.folder,
                                      Colors.purple,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CategoryListScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                const Align(
                                  alignment:
                                      Alignment.centerLeft,
                                  child: Text(
                                    "Quick Actions",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                buildActionTile(
                                  context,
                                  "Add Category",
                                  Icons.add,
                                  const AddCategoryScreen(),
                                ),

                                buildActionTile(
                                  context,
                                  "Appointments",
                                  Icons.calendar_today,
                                  const AdminAppointmentsScreen(),
                                ),

                                buildActionTile(
                                  context,
                                  "Doctors",
                                  Icons.person,
                                  const DoctorListScreen(),
                                ),

                                buildActionTile(
                                  context,
                                  "Time Slots",
                                  Icons.schedule,
                                  ManageTimeSlotsScreen(),
                                ),

                                buildActionTile(
                                  context,
                                  "Profile",
                                  Icons.person_outline,
                                  const ProfileScreen(),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget buildStatCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 20),
              Text(
                "$count",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActionTile(
      BuildContext context,
      String title,
      IconData icon,
      Widget page) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15),
        ),
        leading:
            Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}
