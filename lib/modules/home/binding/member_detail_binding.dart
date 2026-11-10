import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../controller/member_detail_controller.dart';
import 'home_binding.dart';

class MemberDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Connect / Pass / Block live on HomeController; make sure it exists even
    // if this route is opened from somewhere other than Browse Members.
    if (!Get.isRegistered<HomeController>()) {
      HomeBinding().dependencies();
    }
    // Per-screen instance: created on each entry, disposed with the route.
    Get.put<MemberDetailController>(MemberDetailController());
  }
}
