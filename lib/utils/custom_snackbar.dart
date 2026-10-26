// // ignore_for_file: prefer_const_constructors, deprecated_member_use
//
// import 'package:flutter/material.dart';
//
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
//
//
// import '../../routes/app_pages.dart';
// import 'colors/app_colors.dart';
//
//
// class CustomSnackBar {
//   static show({
//     // String? title,
//     String? message,
//     bool isKyc = false,
//     bool isError = false,
//   }) {
//     return Get.snackbar(
//       // title ?? "",
//       "",
//       message ?? "",
//       backgroundColor: isError ? CustomColor.error : CustomColor.secondaryGreen,
//       animationDuration: const Duration(milliseconds: 100),
//       duration: Duration(seconds: isKyc ? 5 : 2),
//       dismissDirection: DismissDirection.down,
//       forwardAnimationCurve: Curves.easeIn,
//       snackPosition: SnackPosition.BOTTOM,
//       padding: const EdgeInsets.all(8),
//       colorText: CustomColor.white,
//       snackStyle: SnackStyle.FLOATING,
//       borderRadius: 8,
//       titleText: const SizedBox(),
//
//       margin: const EdgeInsets.all(8),
//     );
//   }
//
//   static showSuccessPopup({String? message}) {
//     return Get.dialog(
//       Text(message ?? ''),
//     );
//   }
//
//
//
// }
