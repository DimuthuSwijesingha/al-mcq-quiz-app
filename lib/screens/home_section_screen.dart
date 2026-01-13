import 'package:flutter/material.dart';
import 'subject_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_select_path_screen.dart';
import '../widgets/user_dashboard_drawer.dart';
import '../services/home_exit_service.dart';

const Color primaryBlue = Color(0xFF1E3A8A);
const Color adminPurple = Color(0xFF6D28D9);

class HomeSectionScreen extends StatefulWidget {
  const HomeSectionScreen({super.key});

  @override
  State<HomeSectionScreen> createState() => _HomeSectionScreenState();
}

class _HomeSectionScreenState extends State<HomeSectionScreen> {
  bool isAdmin = false;
  bool loading = true;

  Future<void> loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      isAdmin = doc.data()?['role'] == 'admin';
      loading = false;
    });
  }

  Future<void> startHomeExitService() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return;

    final lat = data['homeLat'];
    final lng = data['homeLng'];

    if (lat != null && lng != null) {
      HomeExitService.start(homeLat: lat, homeLng: lng);
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserRole();
    startHomeExitService();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: const UserDashboardDrawer(),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text(
          'Select Section',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isAdmin)
            SectionListItem(
              title: 'Admin Panel',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminSelectPathScreen(forManage: false),
                  ),
                );
              },
            ),

          SectionListItem(
            title: 'A/L MCQ Practice',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubjectScreen(examType: 'AL'),
                ),
              );
            },
          ),

          SectionListItem(
            title: 'O/L MCQ Practice',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubjectScreen(examType: 'OL'),
                ),
              );
            },
          ),

          SectionListItem(
            title: 'Popular School Papers',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),

          SectionListItem(
            title: 'Notes',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SectionListItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SectionListItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
