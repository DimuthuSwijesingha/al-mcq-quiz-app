import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 🆕 NAME CONTROLLER
  final nameController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  Future<void> register() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    // 🧠 NAME VALIDATION
    if (nameController.text.trim().isEmpty) {
      setState(() {
        error = 'Please enter your full name';
        isLoading = false;
      });
      return;
    }

    final passwordError = validatePassword(passwordController.text.trim());

    if (passwordError != null) {
      setState(() {
        error = passwordError;
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // 🔽 SAVE USER TO FIRESTORE (WITH NAME)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'mcqReminderEnabled': false,
            'name': nameController.text.trim(), // 🆕
            'email': userCredential.user!.email,
            'role': 'user',
            'createdAt': Timestamp.now(),
          });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          error = 'This email is already registered';
        } else if (e.code == 'invalid-email') {
          error = 'Invalid email address';
        } else if (e.code == 'weak-password') {
          error = 'Password is too weak';
        } else {
          error = e.message;
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎓 HEADER
              const SizedBox(height: 40),
              const Icon(Icons.person_add_alt_1, size: 64),
              const SizedBox(height: 16),

              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Join and start practicing MCQs',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              // 📦 REGISTER CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 🆕 FULL NAME
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // EMAIL
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PASSWORD RULES
                      const Text(
                        'Password must contain:\n'
                        '• 8+ characters\n'
                        '• Uppercase & lowercase letters\n'
                        '• A number\n'
                        '• A special character',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      // ERROR
                      if (error != null)
                        Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 16),

                      // REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BACK TO LOGIN
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
