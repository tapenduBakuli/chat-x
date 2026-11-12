import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'Store/HiveStore.dart';

/// Service for fetching current device location and storing latitude
/// and longitude into [HiveStore] under [Keys.LATITUDE] and [Keys.LONGITUDE].
class LocationService {
  LocationService._();

  /// Fetches current device latitude and longitude and stores them in HiveStore.
  /// Never throws or blocks app execution.
  static Future<void> fetchAndStoreLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationService: Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            'LocationService: Location permissions are permanently denied.');
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final String lat = position.latitude.toString();
      final String lng = position.longitude.toString();

      final HiveStore store = HiveStore();
      await store.setString(Keys.LATITUDE, lat);
      await store.setString(Keys.LONGITUDE, lng);

      debugPrint('LocationService: Location stored -> Lat: $lat, Lng: $lng');
    } catch (e) {
      debugPrint('LocationService: Error fetching location: $e');
    }
  }
}
