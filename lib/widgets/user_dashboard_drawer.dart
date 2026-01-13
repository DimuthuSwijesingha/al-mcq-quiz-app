import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/map_test_screen.dart';
import '../services/location_service.dart';
import '../services/home_exit_service.dart';
import '../screens/set_home_map_screen.dart';

class UserDashboardDrawer extends StatefulWidget {
  const UserDashboardDrawer({super.key});

  @override
  State<UserDashboardDrawer> createState() => _UserDashboardDrawerState();
}

class _UserDashboardDrawerState extends State<UserDashboardDrawer> {
  final user = FirebaseAuth.instance.currentUser!;

  /// 📍 Set home location using real GPS
  Future<void> _setHomeLocation(BuildContext context) async {
    // 1️⃣ Request permissions
    final granted = await LocationService.requestPermissions();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    // 2️⃣ Get current GPS position
    final position = await LocationService.getCurrentLocation();

    // 3️⃣ Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'homeLat': position.latitude,
      'homeLng': position.longitude,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🏠 Home location saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// 👤 USER HEADER
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};

                return UserAccountsDrawerHeader(
                  accountName: Text(
                    data['name'] ?? 'Student',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(user.email ?? ''),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person, size: 36),
                  ),
                );
              },
            ),

            /// 🔔 MCQ REMINDER SWITCH
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};

                final enabled = data['mcqReminderEnabled'] ?? false;
                final homeLat = data['homeLat'];
                final homeLng = data['homeLng'];

                return SwitchListTile(
                  title: const Text('MCQ Practice Reminder'),
                  subtitle: const Text('Notify when you leave home'),
                  value: enabled,
                  secondary: const Icon(Icons.notifications_active),
                  onChanged: (value) async {
                    // Save switch state
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'mcqReminderEnabled': value});

                    // Start / Stop service
                    if (value == true && homeLat != null && homeLng != null) {
                      HomeExitService.start(homeLat: homeLat, homeLng: homeLng);
                    } else {
                      HomeExitService.stop();
                    }
                  },
                );
              },
            ),

            /// 🏠 SET HOME LOCATION
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Set Home Location'),
              subtitle: const Text('Pick location on map'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SetHomeMapScreen()),
                );
              },
            ),

            const Spacer(),

            /// 🚪 LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Open Map Test'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MapTestScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
