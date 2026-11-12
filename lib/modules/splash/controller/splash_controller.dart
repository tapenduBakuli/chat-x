import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';
import '../../../utils/location_service.dart';
import '../../register/model/onboarding_args.dart';
import '../../register/model/update_profile_response_model.dart';
import '../../register/services/profile_services.dart';

class SplashController extends GetxController {
  RxBool? casual = true.obs;

  /// Minimum time the splash is shown.
  static const Duration _minSplash = Duration(seconds: 3);

  /// Upper bound for the GET /users/me payment check; on timeout → Home.
  static const Duration _profileTimeout = Duration(seconds: 8);

  /// Guards against navigating twice.
  bool _navigated = false;

  @override
  void onReady() {
    print("OnReady");
    // String token = HiveStore().getString(Keys.AUTHTOKEN)??"";
    // HiveStore().setString(Keys.ISFIRSTTIME,"false");
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Ask for permissions and fetch device location to store lat/lng in HiveStore.
    _requestStartupPermissions();
    LocationService.fetchAndStoreLocation();

    if (_hasSession()) {
      _routeWithSession();
    } else {
      Timer(_minSplash, () => _go(Routes.LOGIN));
    }
    super.onReady();
  }

  /// A logged-in session exists only when a real LOGIN stored all three of
  /// these (register never writes the session keys).
  bool _hasSession() {
    final String? email = HiveStore().getString(Keys.SESSIONEMAIL);
    final String? name = HiveStore().getString(Keys.SESSIONDISPLAYNAME);
    final String? token = HiveStore().getString(Keys.ACCESSTOKEN);

    return (email != null && email.isNotEmpty) &&
        (name != null && name.isNotEmpty) &&
        (token != null && token.isNotEmpty);
  }

  /// With a saved session, re-checks GET /users/me so a user who logged in
  /// but never saved a payment method (explicit has_payment_method == false)
  /// resumes onboarding at Payment instead of landing on Home. Any failure or
  /// timeout falls back to Home.
  Future<void> _routeWithSession() async {
    // Started before the minimum delay so both run in parallel.
    final Future<UpdateProfileResponseModel?> profileFuture = ProfileService
        .instance
        .getMyProfile()
        .timeout(_profileTimeout)
        .then<UpdateProfileResponseModel?>((r) => r)
        .catchError((Object _) => null);

    final List<dynamic> results =
        await Future.wait<dynamic>([Future.delayed(_minSplash), profileFuture]);
    final UpdateProfileResponseModel? res =
        results[1] as UpdateProfileResponseModel?;

    if (!_hasSession()) {
      // The session was cleared meanwhile (e.g. token refresh rejected and
      // BaseClient already routed to Login).
      if (Get.currentRoute != Routes.LOGIN) _go(Routes.LOGIN);
      return;
    }

    final UpdateProfileUser? user = res?.data;
    if (res != null &&
        res.success &&
        user != null &&
        requiresPaymentGate(user.hasPaymentMethod)) {
      _go(Routes.PAYMENT, arguments: OnboardingArgs.fromProfileUser(user));
    } else {
      _go(Routes.HOME);
    }
  }

  void _go(String route, {dynamic arguments}) {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(route, arguments: arguments);
  }

  /// Requests the runtime permissions the app relies on. The OS shows its own
  /// prompts; the app continues regardless of the user's choice. Any denied
  /// permission is handled gracefully at the point of use.
  Future<void> _requestStartupPermissions() async {
    try {
      final List<Permission> permissions = [
        Permission.camera,
        Permission.photos, // iOS photo library + Android 13+ READ_MEDIA_IMAGES
        if (defaultTargetPlatform == TargetPlatform.android)
          Permission.storage, // older Android (<= API 32)
      ];

      await permissions.request();
    } catch (e) {
      debugPrint('Startup permission request failed: $e');
    }
  }
}
