import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'Store/HiveStore.dart';
import 'device_coordinates.dart';

/// Outcome of [LocationService.ensureLocation].
enum LocationGateResult { ok, serviceDisabled, denied, deniedForever, failed }

/// Service for fetching current device location and storing latitude
/// and longitude into [HiveStore] under [Keys.LATITUDE] and [Keys.LONGITUDE].
class LocationService {
  LocationService._();

  /// Fetches current device latitude and longitude and stores them in HiveStore.
  /// Never throws or blocks app execution. Delegates to [ensureLocation].
  static Future<void> fetchAndStoreLocation() async {
    await ensureLocation(timeout: const Duration(seconds: 5));
  }

  // [OLD – original void implementation, now delegates to ensureLocation]
  // /// Fetches current device latitude and longitude and stores them in HiveStore.
  // /// Never throws or blocks app execution.
  // static Future<void> fetchAndStoreLocation() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       debugPrint('LocationService: Location services are disabled.');
  //       return;
  //     }

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         debugPrint('LocationService: Location permissions are denied.');
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       debugPrint(
  //           'LocationService: Location permissions are permanently denied.');
  //       return;
  //     }

  //     final Position position = await Geolocator.getCurrentPosition(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.medium,
  //         timeLimit: Duration(seconds: 5),
  //       ),
  //     );

  //     final String lat = position.latitude.toString();
  //     final String lng = position.longitude.toString();

  //     final HiveStore store = HiveStore();
  //     await store.setString(Keys.LATITUDE, lat);
  //     await store.setString(Keys.LONGITUDE, lng);

  //     debugPrint('LocationService: Location stored -> Lat: $lat, Lng: $lng');
  //   } catch (e) {
  //     debugPrint('LocationService: Error fetching location: $e');
  //   }
  // }
  // [/OLD]

  /// Pure mapping from service/permission state to a blocking result, or
  /// null when a position may be requested.
  @visibleForTesting
  static LocationGateResult? blockingResultFor({
    required bool serviceEnabled,
    required LocationPermission permission,
  }) {
    if (!serviceEnabled) return LocationGateResult.serviceDisabled;
    if (permission == LocationPermission.deniedForever) {
      return LocationGateResult.deniedForever;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return LocationGateResult.denied;
    }
    return null;
  }

  /// Makes sure coordinates are stored and reports why not otherwise.
  /// Never throws. If valid coordinates are already stored and permission is
  /// granted, returns [LocationGateResult.ok] at once and refreshes in the
  /// background.
  static Future<LocationGateResult> ensureLocation({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (serviceEnabled &&
          storedDeviceCoordinates() != null &&
          blockingResultFor(
                  serviceEnabled: serviceEnabled, permission: permission) ==
              null) {
        _fetchAndStore(timeout); // background refresh, errors swallowed
        return LocationGateResult.ok;
      }

      if (serviceEnabled && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final LocationGateResult? blocked = blockingResultFor(
          serviceEnabled: serviceEnabled, permission: permission);
      if (blocked != null) {
        debugPrint('LocationService: blocked -> $blocked');
        return blocked;
      }
      return await _fetchAndStore(timeout)
          ? LocationGateResult.ok
          : LocationGateResult.failed;
    } catch (e) {
      debugPrint('LocationService: Error ensuring location: $e');
      return LocationGateResult.failed;
    }
  }

  static Future<bool> _fetchAndStore(Duration timeout) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        ),
      );
      final HiveStore store = HiveStore();
      await store.setString(Keys.LATITUDE, position.latitude.toString());
      await store.setString(Keys.LONGITUDE, position.longitude.toString());
      debugPrint('LocationService: Location stored');
      return true;
    } catch (e) {
      debugPrint('LocationService: Error fetching location: $e');
      return false;
    }
  }
}
