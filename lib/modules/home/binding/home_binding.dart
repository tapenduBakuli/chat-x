import 'package:get/get.dart';

import '../controller/friends_controller.dart';
import '../controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Friends tab (Friend Requests + My Friends). Demo data until APIs land.
    Get.lazyPut<FriendsController>(
      () => FriendsController(),
    );
  }
}
