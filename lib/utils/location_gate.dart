import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../device_manager/screen_constants.dart';
import 'TextStyles.dart';
import 'colors/app_colors.dart';
import 'location_service.dart';

/// Dialog copy for a blocking [LocationGateResult].
class LocationGateCopy {
  const LocationGateCopy(this.reason, this.actionLabel);
  final String reason;
  final String actionLabel;
}

/// Pure mapping: result -> dialog copy. null for [LocationGateResult.ok].
LocationGateCopy? locationGateCopyFor(LocationGateResult r) {
  switch (r) {
    case LocationGateResult.ok:
      return null;
    case LocationGateResult.serviceDisabled:
      return const LocationGateCopy(
          'Turn on location services', 'Open settings');
    case LocationGateResult.denied:
      return const LocationGateCopy(
          'Please allow location access to continue.', 'Allow location');
    case LocationGateResult.deniedForever:
      return const LocationGateCopy(
          'Location permission is blocked. Enable it in Settings.',
          'Open settings');
    case LocationGateResult.failed:
      return const LocationGateCopy("Couldn't get your location", 'Try again');
  }
}

bool _gateBusy = false;

/// Location gate (product rule: no login / sign-up without coordinates).
/// Returns true when coordinates are available. Otherwise shows a dialog and
/// returns false (or true if the user fixes it and retries successfully).
/// Single-flight: a call while another is running returns false.
Future<bool> requireLocation() async {
  if (_gateBusy) return false;
  _gateBusy = true;
  try {
    while (true) {
      final LocationGateResult result = await LocationService.ensureLocation();
      debugPrint('LocationGate: result -> $result');
      final LocationGateCopy? copy = locationGateCopyFor(result);
      if (copy == null) return true;

      final bool? retry = await Get.dialog<bool>(
        _LocationDialog(result: result, copy: copy),
        barrierDismissible: true,
      );
      if (retry != true) return false;
      // Settings actions: user returns and taps the action again.
      if (result == LocationGateResult.serviceDisabled ||
          result == LocationGateResult.deniedForever) {
        return false;
      }
    }
  } catch (e) {
    debugPrint('LocationGate: error $e');
    return false;
  } finally {
    _gateBusy = false;
  }
}

class _LocationDialog extends StatelessWidget {
  const _LocationDialog({required this.result, required this.copy});
  final LocationGateResult result;
  final LocationGateCopy copy;

  Future<void> _onAction() async {
    switch (result) {
      case LocationGateResult.serviceDisabled:
        await Geolocator.openLocationSettings();
        break;
      case LocationGateResult.deniedForever:
        await Geolocator.openAppSettings();
        break;
      default:
        break;
    }
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CustomColor.colorWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Location is required to use ChatX',
        style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
      ),
      content: Text(copy.reason, style: TextStyles.loginWelcomeSubtitle),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: TextStyles.loginWelcome.copyWith(
              fontSize: FontSize.s14,
              color: CustomColor.color64748B,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.colorE11D48,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            copy.actionLabel,
            style: TextStyles.loginWelcome.copyWith(
              fontSize: FontSize.s14,
              color: CustomColor.colorWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
