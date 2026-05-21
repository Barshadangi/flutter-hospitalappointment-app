import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_appointments_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2F80ED),
                  Color(0xFF56CCF2)
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 55,
                      color: Color(0xFF2F80ED)),
                ),
                const SizedBox(height: 15),
                Text(
                  user?.displayName ?? "User Name",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              children: [
                buildTile(
                  context,
                  icon: Icons.calendar_month,
                  title: "My Appointments",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                             MyAppointmentsScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context,
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context,
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context,
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                buildTile(
                  context,
                  icon: Icons.logout,
                  title: "Logout",
                  isLogout: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15), // ✅ fixed
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : const Color(0xFF2F80ED),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color:
                isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Notifications")),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          notificationCard(
              "Appointment Confirmed",
              "Your appointment with Dr. Sharma is confirmed.",
              Icons.check_circle,
              Colors.green),
          notificationCard(
              "Reminder",
              "You have an appointment tomorrow at 10 AM.",
              Icons.access_time,
              Colors.orange),
        ],
      ),
    );
  }

  Widget notificationCard(
      String title,
      String subtitle,
      IconData icon,
      Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1), // ✅ fixed
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                color.withValues(alpha: 0.1), // ✅ fixed
            child:
                Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight:
                            FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Help & Support")),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          faqTile(
              "How do I book an appointment?",
              "Select department → Choose doctor → Tap Book Appointment."),
          faqTile(
              "How do I cancel appointment?",
              "Go to My Appointments and cancel from there."),
          const SizedBox(height: 30),
          const Text(
            "Contact Support",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          contactCard(Icons.email,
              "support@sewabook.com"),
          contactCard(
              Icons.phone, "+977-9800000000"),
        ],
      ),
    );
  }

  Widget faqTile(String question,
      String answer) {
    return ExpansionTile(
      title: Text(question,
          style: const TextStyle(
              fontWeight:
                  FontWeight.w500)),
      children: [
        Padding(
          padding:
              const EdgeInsets.all(12),
          child: Text(answer),
        )
      ],
    );
  }

  Widget contactCard(
      IconData icon, String text) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon,
            color: const Color(0xFF2F80ED)),
        title: Text(text),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller =
        TextEditingController(
            text: user?.displayName ?? "");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2F80ED),
                ),
                onPressed: () async {
                  await user?.updateDisplayName(
                      controller.text);

                  if (!mounted) return; // ✅ mounted fix

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content:
                            Text("Profile Updated")),
                  );
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
