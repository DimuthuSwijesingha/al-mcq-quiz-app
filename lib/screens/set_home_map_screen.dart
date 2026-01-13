import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetHomeMapScreen extends StatefulWidget {
  const SetHomeMapScreen({super.key});

  @override
  State<SetHomeMapScreen> createState() => _SetHomeMapScreenState();
}

class _SetHomeMapScreenState extends State<SetHomeMapScreen> {
  GoogleMapController? _controller;
  LatLng? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Home Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.9271, 79.8612), // Colombo
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
            onTap: (latLng) {
              setState(() {
                _selected = latLng;
              });

              _controller?.animateCamera(
                CameraUpdate.newLatLng(latLng),
              );
            },
            markers: _selected == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('home'),
                      position: _selected!,
                      infoWindow: const InfoWindow(
                        title: 'Home Location',
                      ),
                    ),
                  },
          ),

          // Instruction overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              color: Colors.black87,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '📍 Tap on the map to select your home location',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selected == null ? null : _saveHome,
        icon: const Icon(Icons.home),
        label: const Text('Save Home'),
      ),
    );
  }

  Future<void> _saveHome() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'homeLat': _selected!.latitude,
      'homeLng': _selected!.longitude,
    });

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🏠 Home location saved')),
    );
  }
}
