import 'package:get/get.dart';

import '../controller/blocked_controller.dart';
import '../controller/friends_controller.dart';
import '../controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Friends tab (Friend Requests, My Friends, Sent Requests) — API-backed.
    Get.lazyPut<FriendsController>(
      () => FriendsController(),
    );
    // Blocked tab (GET users/blocked + unblock).
    Get.lazyPut<BlockedController>(
      () => BlockedController(),
    );
  }
}
