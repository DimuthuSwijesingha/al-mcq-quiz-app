import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class HomeExitService {
  static bool _started = false;
  static Position? _home;
  static bool _notified = false;

  static void start({
    required double homeLat,
    required double homeLng,
  }) {
    if (_started) return;
    _started = true;

    // ✅ FIXED Position constructor (geolocator v10+)
    _home = Position(
      latitude: homeLat,
      longitude: homeLng,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      isMocked: false,
    );

    debugPrint('🏠 HomeExitService started at $homeLat, $homeLng');

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    ).listen((pos) async {
      if (_home == null) return;

      final distance = Geolocator.distanceBetween(
        _home!.latitude,
        _home!.longitude,
        pos.latitude,
        pos.longitude,
      );

      debugPrint('📏 Distance from home: ${distance.toStringAsFixed(2)}m');

      if (distance > 10 && !_notified) {
        _notified = true;
        debugPrint('🚨 EXIT detected → sending notification');
        await NotificationService.showReminderNotification();
      }

      // 🔁 Reset when user comes back home
      if (distance <= 10) {
        _notified = false;
      }
    });
  }

  static void stop() {
    debugPrint('🛑 HomeExitService stopped');
    _started = false;
    _notified = false;
  }
}
