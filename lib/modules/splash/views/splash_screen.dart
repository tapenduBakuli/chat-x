import 'package:chat_x/modules/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/custom_widgets/logo_card.dart';
import '../../../utils/custom_widgets/verified_badge.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return controller.casual!.value?Scaffold(
      body: SafeArea(
        child: Container(
          width: Get.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF6EEFB), // soft lilac top
                Color(0xFFF4ECFA),
                Color(0xFFFAF5FF), // near white bottom
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               LogoCard(),
              const SizedBox(height: 32),
              Text(
                "Find genuine connections",
                textAlign: TextAlign.center,
                style: TextStyles.landingTitle,
              ),
              const SizedBox(height: 14),
              Text(
                "Discreet, secure, and made for adults.\nReal chat with real people.",
                textAlign: TextAlign.center,
                style: TextStyles.landingSubTitle,
              ),
              const SizedBox(height: 28),
              VerifiedBadge(text: "18+ Exclusive & Verified"),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ):const Offstage();
  }
}






