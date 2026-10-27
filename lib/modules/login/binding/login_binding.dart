import 'package:get/get.dart';

import '../controller/login_controller.dart';

class LoginBinding extends Bindings{
  @override
  void dependencies() {
    // One stable, permanent LoginController shared across the whole auth flow
    // (login / forgot-password / otp / reset). Using permanent:true means GetX
    // never disposes or recreates it during navigation, so every screen's
    // widgets reference the SAME instance — fixing both the "controller used
    // after disposed" crash and the Remember-me toggle not updating after
    // returning from the forgot-password screen.
    if (Get.isRegistered<LoginController>()) return;
    Get.put<LoginController>(LoginController(), permanent: true);
  }
}