import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class LocationDebug {
  static bool _started = false;
  static Position? _lastPosition;

  static void start() {
    if (_started) return;
    _started = true;

    debugPrint('🧭 Starting LIVE GPS debug stream');

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // 🔥 trigger every 5 meters
      ),
    ).listen((pos) async {
      debugPrint(
        '📍 LIVE → ${pos.latitude}, ${pos.longitude} (±${pos.accuracy}m)',
      );

      // 🔥 SEND TEST NOTIFICATION ON MOVEMENT
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          pos.latitude,
          pos.longitude,
        );

        if (distance > 5) {
          debugPrint('🚨 MOVED $distance meters → sending notification');
          await NotificationService.showReminderNotification();
        }
      }

      _lastPosition = pos;
    });
  }
}
