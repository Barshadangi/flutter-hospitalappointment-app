import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController adminCodeController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<void> signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      // 🔐 Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String role = "user";

      // 🔑 Admin Code Check
      if (adminCodeController.text.trim() == "ADMIN123") {
        role = "admin";
      }

      // 📦 Save user in Firestore
      await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "email": emailController.text.trim(),
        "role": role,
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            role == "admin"
                ? "Admin account created successfully"
                : "Account created successfully",
          ),
        ),
      );

      // 🚀 Go to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      String message = "Signup failed";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    adminCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add,
                    size: 70, color: Color(0xFF2F80ED)),

                const SizedBox(height: 20),

                const Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                // 📧 Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter email";
                    }
                    if (!value.contains('@')) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 🔒 Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter password";
                    }
                    if (value.length < 6) {
                      return "Minimum 6 characters required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 🔒 Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 👑 Admin Code
                TextFormField(
                  controller: adminCodeController,
                  decoration: const InputDecoration(
                    labelText: "Admin Code (Optional)",
                    prefixIcon: Icon(Icons.admin_panel_settings),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔘 Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signUpUser,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF2F80ED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
