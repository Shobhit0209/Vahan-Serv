import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vahanserv/Models/location_data_model.dart';

class LocationService {
  // Method 1: Get current location once (for immediate use)
  static Future<LocationData?> getCurrentLocationData() async {
    try {
      // Check permissions first
      bool hasPermission = await _checkPermissions();
      if (!hasPermission) {
        if (kDebugMode) {
          print("Location permission not granted");
        }
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      return LocationData(
        lat: position.latitude,
        long: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error getting current location: $e");
      }
      return null;
    }
  }

  static Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
