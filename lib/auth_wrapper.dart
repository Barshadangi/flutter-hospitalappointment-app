import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth/login_screen.dart';
import 'home/user_home.dart';
import 'home/admin_home.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        // 🔄 Firebase Auth Loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ If NOT logged in
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        final user = authSnapshot.data!;

        // ✅ If logged in → listen to Firestore role
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots(),
          builder: (context, roleSnapshot) {

            // 🔄 Firestore Loading
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ❌ Firestore Error
            if (roleSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text("Firestore Error: ${roleSnapshot.error}"),
                ),
              );
            }

            // ❌ If document does NOT exist
            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            // ✅ Get role safely
            final data =
                roleSnapshot.data!.data() as Map<String, dynamic>?;

            final String role = data?["role"] ?? "user";

            // 🔐 Role routing
            if (role == "admin") {
              return const AdminHome();
            } else {
              return const UserHome();
            }
          },
        );
      },
    );
  }
}
