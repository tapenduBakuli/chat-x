import 'package:get/get.dart';

import '../controller/blocked_controller.dart';
import '../controller/conversations_controller.dart';
import '../controller/friends_controller.dart';
import '../controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // The tab controllers below are also reached from pushed routes (Member
    // Details, Chat). If the FIRST Get.find happens while such a route is on
    // top, GetX binds the instance to that route and deletes it when the route
    // pops; without `fenix` the factory is gone too, so the tab then throws
    // "<Controller> not found". `fenix: true` recreates it on the next find.
    //
    // Friends tab (Saved profiles) — API-backed.
    Get.lazyPut<FriendsController>(
      () => FriendsController(),
      fenix: true,
    );
    // Blocked tab (GET users/blocked + unblock).
    Get.lazyPut<BlockedController>(
      () => BlockedController(),
      fenix: true,
    );
    // Chat tab (GET conversations).
    Get.lazyPut<ConversationsController>(
      () => ConversationsController(),
      fenix: true,
    );
  }
}
