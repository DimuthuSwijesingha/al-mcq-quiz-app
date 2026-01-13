import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Request location permissions
  static Future<bool> requestPermissions() async {
    final location = await Permission.location.request();
    final background = await Permission.locationAlways.request();

    return location.isGranted && background.isGranted;
  }

  /// Get current GPS position
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
