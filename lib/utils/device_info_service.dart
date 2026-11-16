import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'Store/HiveStore.dart';

/// Fetches the device id + device type once on app open and keeps them in
/// Hive. Never throws: on any error `deviceId` is null and `deviceType` is
/// still set.
class DeviceInfoService {
  DeviceInfoService._();

  static final DeviceInfoService instance = DeviceInfoService._();

  String? _deviceId;
  String _deviceType = 'web';
  Future<void>? _initFuture;

  String? get deviceId => _deviceId;
  String get deviceType => _deviceType;

  /// Ready to be spread into an API body as the `device` block.
  Map<String, dynamic> deviceBlock() => {
        'device_id': deviceId,
        'device_type': deviceType,
      };

  /// Single-flight: concurrent callers await the same Future.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    _deviceType = _detectType();

    // Hive first so later launches are instant.
    try {
      final String saved = HiveStore().getStringQuiet(Keys.DEVICEID);
      if (saved.isNotEmpty) _deviceId = saved;
    } catch (_) {}

    try {
      _deviceId = await _fetchDeviceId();
    } catch (e) {
      debugPrint('DeviceInfoService: failed to read device id: $e');
      // Keep any previously saved id; otherwise null.
    }

    try {
      await HiveStore().setStringQuiet(Keys.DEVICETYPE, _deviceType);
      final String? id = _deviceId;
      if (id != null && id.isNotEmpty) {
        await HiveStore().setStringQuiet(Keys.DEVICEID, id);
      }
    } catch (e) {
      debugPrint('DeviceInfoService: failed to save to Hive: $e');
    }

    debugPrint('DeviceInfoService: type=$_deviceType id=$_deviceId');
  }

  String _detectType() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'web';
    }
  }

  Future<String?> _fetchDeviceId() async {
    switch (_deviceType) {
      case 'ios':
        final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
        return info.identifierForVendor;
      case 'android':
        // AndroidDeviceInfo.id is the Android BUILD id (e.g. TP1A.220624.014),
        // shared by every device on the same build, so it is NOT a device id.
        // Use a stable per-install UUID generated once and kept in Hive.
        // TODO: use the android_id package if the backend needs the real ANDROID_ID
        String install = HiveStore().getStringQuiet(Keys.DEVICEINSTALLID);
        if (install.isEmpty) {
          install = generateUuidV4();
          await HiveStore().setStringQuiet(Keys.DEVICEINSTALLID, install);
        }
        return install;
      default:
        return null;
    }
  }

  /// RFC 4122 version 4 UUID from a secure random source.
  @visibleForTesting
  static String generateUuidV4([Random? random]) {
    final Random r = random ?? Random.secure();
    final List<int> b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final String h = b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
