import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_section_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_home_screen.dart';
import '../widgets/app_loading_screen.dart';



class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
  return const AppLoadingScreen(
    message: 'Checking authentication...',
  );
}


       if (snapshot.hasData) {
  final user = snapshot.data!;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(),
    builder: (context, roleSnapshot) {
      if (!roleSnapshot.hasData) {
  return const AppLoadingScreen(
    message: 'Loading your profile...',
  );
}


      final role = roleSnapshot.data!['role'];

      if (role == 'admin') {
        return const AdminHomeScreen();
      } else {
        return const HomeSectionScreen();
      }
    },
  );
}


        // User is NOT logged in
        return const LoginScreen();
      },
    );
  }
}
