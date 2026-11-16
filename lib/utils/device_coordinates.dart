import 'Store/HiveStore.dart';
import 'auth_payload_builders.dart';
import 'device_info_service.dart';

/// Device coordinates stored by LocationService (Keys.LATITUDE/LONGITUDE,
/// saved as strings at app start / Home open). null when missing, not a
/// number, or outside the API's valid range.
({double lat, double lng})? storedDeviceCoordinates() {
  final HiveStore store = HiveStore();
  final double? lat = double.tryParse(store.getStringQuiet(Keys.LATITUDE).trim());
  final double? lng =
      double.tryParse(store.getStringQuiet(Keys.LONGITUDE).trim());
  if (lat == null || lng == null) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return (lat: lat, lng: lng);
}

/// `device` block for auth calls. Never throws.
Future<Map<String, dynamic>?> currentDeviceBlock() async {
  try {
    await DeviceInfoService.instance.init();
    final DeviceInfoService d = DeviceInfoService.instance;
    return buildDeviceBlock(deviceId: d.deviceId, deviceType: d.deviceType);
  } catch (_) {
    return null;
  }
}

/// Register `location` from stored coordinates + the user's state/city.
/// Never throws.
Map<String, dynamic>? currentRegisterLocation({String? city, String? region}) {
  try {
    final c = storedDeviceCoordinates();
    return buildRegisterLocation(
      latitude: c?.lat,
      longitude: c?.lng,
      city: city,
      region: region,
    );
  } catch (_) {
    return null;
  }
}

/// Login `location` (lat/lng only) from stored coordinates. Never throws.
Map<String, dynamic>? currentLoginLocation() {
  try {
    final c = storedDeviceCoordinates();
    return buildLoginLocation(latitude: c?.lat, longitude: c?.lng);
  } catch (_) {
    return null;
  }
}
