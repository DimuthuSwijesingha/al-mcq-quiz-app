import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTestScreen extends StatelessWidget {
  const MapTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Test')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(6.9271, 79.8612), // Colombo
          zoom: 14,
        ),
      ),
    );
  }
}
