import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';

class SplashController extends GetxController {
  RxBool? casual = true.obs;

  @override
  void onReady() {
    print("OnReady");
    // String token = HiveStore().getString(Keys.AUTHTOKEN)??"";
    // HiveStore().setString(Keys.ISFIRSTTIME,"false");
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Ask for all permissions the app needs (camera + photos/storage) up front,
    // so later screens (e.g. Profile Setup) can open the camera/gallery
    // directly without prompting again on the happy path.
    _requestStartupPermissions();

    Timer(const Duration(seconds: 3), () async {
      // A logged-in session exists only when a real LOGIN stored all three of
      // these (register never writes the session keys). Otherwise go to Login.
      final String? email = HiveStore().getString(Keys.SESSIONEMAIL);
      final String? name = HiveStore().getString(Keys.SESSIONDISPLAYNAME);
      final String? token = HiveStore().getString(Keys.ACCESSTOKEN);

      final bool hasSession = (email != null && email.isNotEmpty) &&
          (name != null && name.isNotEmpty) &&
          (token != null && token.isNotEmpty);

      if (hasSession) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
    super.onReady();
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
