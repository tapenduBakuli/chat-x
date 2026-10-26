// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../device_manager/screen_constants.dart';
// import '../device_manager/urls.dart';
// import 'Store/HiveStore.dart';
// import 'TextStyles.dart';
// import 'colors/app_colors.dart';
// import 'text_utils/app_strings.dart';
// import 'fonts.dart';
//
// launchUrls(Uri url) async {
//   if (!await launchUrl(url)) {
//     throw Exception('Could not launch $url');
//   }
// }
//
// void showFailureSnackBar(String? title, String msg) {
//   clearSnackBars();
//   Get.snackbar(
//       "",
//       "",
//       messageText: const Offstage(),
//       titleText: Padding(
//         padding: EdgeInsets.only(top: ScreenConstant.defaultHeightFour),
//         child: Text(
//           msg,
//           style: TextStyles.hintTextStyle.copyWith(color: CustomColor.fillOffWhiteColor,fontSize: 13,fontWeight: FontWeight.w500),
//         ),
//       ),
//       icon: const Icon(Icons.error_outline_rounded,color: CustomColor.white,),
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: CustomColor.containerColor3,
//       colorText: CustomColor.white,
//   duration: Duration(seconds: 1),
//   margin: EdgeInsets.symmetric(horizontal: ScreenConstant.screenWidthMinimum, vertical: ScreenConstant.screenHeightMinimum));
// }
//
// void showFailureSnackBarForOffline(String? title, String msg) {
//   clearSnackBars();
//   Get.snackbar(
//       "",
//       "",
//       messageText: const Offstage(),
//       titleText: Padding(
//         padding: EdgeInsets.only(top: ScreenConstant.defaultHeightFour),
//         child: Text(
//           msg,
//           style: TextStyles.hintTextStyle.copyWith(color: CustomColor.fillOffWhiteColor,fontSize: 13,fontWeight: FontWeight.w500),
//         ),
//       ),
//       icon: const Icon(Icons.error_outline_rounded,color: CustomColor.white,),
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: CustomColor.containerColor3.withOpacity(0.4),
//       colorText: CustomColor.white,
//       margin: EdgeInsets.symmetric(horizontal: ScreenConstant.screenWidthMinimum, vertical: ScreenConstant.screenHeightMinimum));
// }
//
// void showSuccessSnackBarForOnline(String? title, String msg) {
//   clearSnackBars();
//   Get.snackbar(title ?? AppStrings.oops.tr, msg, snackPosition: SnackPosition.TOP,
//       backgroundColor: CustomColor.buttonDarkColor.withOpacity(0.4),
//       colorText: CustomColor.white,
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.all(20)
//   );
// }
// void showSuccessSnackBar(String? title, String msg) {
//   clearSnackBars();
//   Get.snackbar(
//     "",
//     "",
//     messageText: const Offstage(),
//     titleText: Padding(
//       padding: EdgeInsets.only(top: ScreenConstant.defaultHeightFour),
//       child: Text(
//         msg,
//         style: TextStyles.hintTextStyle.copyWith(color: CustomColor.fillOffWhiteColor,fontSize: 13,fontWeight: FontWeight.w500),
//       ),
//     ),
//     icon: const Icon(Icons.done),
//     snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: CustomColor.primaryBlue,
//     colorText: CustomColor.white,
//     margin: EdgeInsets.symmetric(horizontal: ScreenConstant.screenWidthMinimum, vertical: ScreenConstant.screenHeightMinimum),
//     duration: Duration(seconds: 1)
//   );
// }
//
// clearSnackBars() {
//   Get.closeAllSnackbars();
// }
//
// bool isGraterDate(String startDate, String endDate) {
//   bool isGrater = false;
//   try {
//     DateTime dt1 = DateTime.parse(startDate);
//     DateTime dt2 = DateTime.parse(endDate);
//
//     if (dt1.compareTo(dt2) == 0) {
//       debugPrint("Both date time are at same moment.");
//       return false;
//     }
//
//     if (dt1.compareTo(dt2) < 0) {
//       debugPrint("DT1 is before DT2");
//       return false;
//     }
//
//     if (dt1.compareTo(dt2) > 0) {
//       debugPrint("DT1 is after DT2");
//       return true;
//     }
//   } catch (e) {}
//   return isGrater;
// }
//
// Future modalBottomSheetMenu(
//     BuildContext context,
//     Widget? titleWidget,
//     Widget? valueWidget,
//     String? hintText,
//     Function()? increase,
//     Function()? decrease,
//     Function(String? val)? onChange,
//     ) async {
//   await showModalBottomSheet(
//       backgroundColor: CustomColor.fillOffWhiteColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(25.0),
//         ),
//       ),
//       context: context,
//       builder: (builder) {
//         return Container(
//           height: ScreenConstant.screenHeightThird,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(25.0),
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 28.0),
//               child: Column(
//                 children: [
//                   Container(
//                     height: ScreenConstant.defaultHeightTwentyThree,
//                   ),
//                   titleWidget ?? const Offstage(),
//                   Container(
//                     height: ScreenConstant.defaultHeightTen,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: CustomColor.colorBorder),
//                           borderRadius: BorderRadius.circular(5)),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               IconButton(
//                                   splashRadius: 1,
//                                   onPressed: increase,
//                                   icon: const Icon(
//                                     Icons.remove,
//                                     size: 30,
//                                   )),
//                               Container(
//                                 color: CustomColor.colorBgVoteCast,
//                                 width: 1,
//                                 height: 40,
//                               ),
//                             ],
//                           ),
//                           DropdownButton(
//                             iconSize: 0.0,
//                             underline: const SizedBox.shrink(),
//                             alignment: Alignment.center,
//                             style: TextStyles.textStyleRegular.apply(
//                                 color: Colors.black, fontSizeFactor: 1.7),
//                             hint: RichText(
//                               text: TextSpan(
//                                   text: hintText,
//                                   style: TextStyles.textStyleRegular.apply(
//                                       color: Colors.black, fontSizeFactor: 1.7),
//                                   children: <TextSpan>[
//                                     TextSpan(
//                                       //text: " ${AppStrings.tos.tr}",
//                                       style: TextStyles.textStyleRegular
//                                           .apply(fontSizeFactor: 1.3),
//                                     ),
//                                   ]),
//                             ),
//                             items: <String>[
//                               "10000 TOS",
//                               "20000 TOS",
//                               "50000 TOS",
//                               "100000 TOS"
//                             ].map(
//                               (val) {
//                                 return DropdownMenuItem<String>(
//                                   value: val,
//                                   child: Text(
//                                     val,
//                                     textAlign: TextAlign.end,
//                                     style: TextStyles.textStyleRegular.apply(
//                                         color: Colors.black,
//                                         fontSizeFactor: 1.7),
//                                   ),
//                                 );
//                               },
//                             ).toList(),
//                             onChanged: (String? val) {
//                               // textController.text =
//                               //     val.toString().replaceAll(" TOS", "");
//                               // _usd =
//                               //     (int.parse(val.toString().replaceAll(" TOS", "")) /
//                               //         _tosToken)
//                               //         .ceil();
//                             },
//                           ),
//                           Row(
//                             children: [
//                               Container(
//                                 color: CustomColor.colorBgVoteCast,
//                                 width: 1,
//                                 height: 40,
//                               ),
//                               IconButton(
//                                   splashRadius: 1,
//                                   onPressed: decrease,
//                                   icon: const Icon(
//                                     Icons.add,
//                                     size: 30,
//                                   )),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       valueWidget ?? const Offstage(),
//                       Container(
//                         width: ScreenConstant.defaultWidthTen,
//                       ),
//                       const Text("= 1 USD")
//                     ],
//                   ),
//
//                 ],
//               ),
//             ),
//           ),
//         );
//       });
//   // return choosedImage;
// }
//
// void showLogoutDialog(Function()? onYesTapped) {
//   Get.defaultDialog(
//       title: "Warning",
//       content: Text(
//         "Do you want to logout?",
//         style: CustomTextStyle(),
//       ),
//       onCancel: () {
//         Get.back();
//       },
//       onConfirm: onYesTapped,
//       buttonColor: CustomColor.chatPaymentBackground,
//       textConfirm: "Yes",
//       textCancel: "No",
//       cancelTextColor: CustomColor.chatPaymentBackground);
// }
//
// void showErrorDialog(Function()? onYesTapped) {
//   Get.defaultDialog(
//       title: "Warning",
//       content: Text(
//         "Do you want to logout?",
//         style: CustomTextStyle(),
//       ),
//       onCancel: () {
//         Get.back();
//       },
//       onConfirm: onYesTapped,
//       buttonColor: CustomColor.chatPaymentBackground,
//       textConfirm: "Yes",
//       textCancel: "No",
//       cancelTextColor: CustomColor.chatPaymentBackground);
// }
//
// void showVersionUpdateDialog(Function()? onCancelTap,Function()? onConfirmTap) {
//   Get.defaultDialog(backgroundColor: CustomColor.error.withOpacity(0.8),barrierDismissible: false,
//       title: "Update Available",titleStyle: TextStyles.appbarTitle.copyWith(fontSize: 16,color: CustomColor.white),
//       content: Text(
//         "Dear employee, please update to latest version to continue using the app.",
//         style: TextStyles.appbarTitle.copyWith(fontSize: 14,color: CustomColor.white),
//         textAlign: TextAlign.center,
//       ),
//       onCancel: onCancelTap,
//       onConfirm: onConfirmTap,
//       buttonColor: CustomColor.chatPaymentBackground,
//       textCancel: "Close",
//       textConfirm: "Update",
//       cancelTextColor: CustomColor.white);
// }
//
// void openPlayStore() async {
//   const url = 'https://play.google.com/store/apps/details?id=com.aiMobileIdeaBox.ssb_oil_palm';
//   if (await canLaunchUrl(Uri.parse(url))) {
//     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//   } else {
//     Get.snackbar("Error", "Could not open the Play Store.");
//   }
// }
//
// void showFailureSnackbar( String? title,String msg){
//   Get.snackbar(title??AppStrings.oops.tr,msg,snackPosition: SnackPosition.TOP,
//       backgroundColor: CustomColor.homeGrey,
//       colorText: Colors.red,
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.all(20)
//   );
// }
// void showSuccessSnackbar( String? title,String msg) {
//   Get.snackbar(title ?? AppStrings.oops.tr, msg, snackPosition: SnackPosition.TOP,
//       backgroundColor: CustomColor.buttonDarkColor,
//       colorText: CustomColor.white,
//       padding: const EdgeInsets.all(20),animationDuration: Duration(seconds: 1),
//       margin: const EdgeInsets.all(20),duration: Duration(seconds: 1)
//   );
// }
// Widget redHeartCurrency(
//   String? firstText,
//   String? imageName,
//   TextStyle? firstTextStyle,
// ) {
//   return Row(
//     children: [
//       Text(
//         firstText ?? "",
//         style: firstTextStyle,
//       ),
//       Container(
//         width: ScreenConstant.defaultWidthTen,
//       ),
//       ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           height: ScreenConstant.defaultHeightTwentyThree,
//           width: ScreenConstant.defaultWidthTwentyThree,
//           padding: const EdgeInsets.all(5),
//           decoration: const BoxDecoration(color: CustomColor.secondaryOffWhiteColor),
//           child: Center(
//             child: Image.asset(imageName!,color: CustomColor.secondaryBlue,),
//           ),
//         ),
//       )
//     ],
//   );
// }
//
// void showNotificationSnackbar(
//     {required String title,
//     required String msg,
//     Function(String?)? onNotificationTap}) {
//   Get.snackbar(title, msg,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: CustomColor.chatPaymentBackground,
//       colorText: CustomColor.chatPaymentBackground,
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.all(20),
//       onTap: (value) => onNotificationTap);
// }
//
// emailValidator(String? email) {
//   Pattern pattern =
//       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//   RegExp regex = new RegExp(pattern.toString());
//   if (email == null || email.isEmpty) {
//     return 'Email is empty';
//   }
//   if (!(regex.hasMatch(email))) {
//     return "Please enter a valid email";
//   }
//   return null;
// }
//
// mobileValidator(String? mobile) {
//   if (mobile == null || mobile.isEmpty) {
//     return 'Mobile no is empty';
//   }
//   if (mobile.length < 10) {
//     return "Please enter a valid mobile no";
//   }
//   return null;
// }
//
// Widget Gap(double gap ){
//   return SizedBox(height: gap,);
// }
//
// Future removeWorker(BuildContext context,String? name,String? taskName, String? index, Function()? confirmOnTap,Function()? cancelOnTap) async {
//   await showModalBottomSheet(
//       backgroundColor: Get.theme.colorScheme.onPrimary,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(25.0),
//         ),
//       ),
//       context: context,
//       builder: (builder) {
//         return Container(
//           height: ScreenConstant.screenHeightThirdAndHalf,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(25.0),
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 28.0),
//               child: Column(
//                 children: [
//                   Gap(10),
//                   Container(
//                     width: 54,
//                     height: 3,
//                     decoration: ShapeDecoration(
//                       color: CustomColor.error,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     ),
//                   ),
//                   Container(height: ScreenConstant.defaultHeightTwentyThree,),
//                   Text(
//                     "${AppStrings.areYouWantTo.tr} $name ${AppStrings.fromTask.tr} $taskName",
//                     style: TextStyles.headingBold.copyWith(fontSize: 16),textAlign: TextAlign.center,
//                   ),
//                   Container(height: ScreenConstant.defaultHeightFifteen,),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                         fixedSize: WidgetStateProperty.all<Size>(
//                           const Size(345.0, 48.0), // Set the desired width and height
//                         ),
//                         shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0), // Adjust the value as needed
//                           ),
//                         ),
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                             CustomColor.error)),
//                     onPressed: confirmOnTap,
//                     child: Text(AppStrings.confirm.tr,style: TextStyles.buttonText,),
//                   ),
//                   Container(height: ScreenConstant.defaultHeightTwentyThree,),
//                   InkWell(
//                     onTap: cancelOnTap,
//                     child: Text(
//                       AppStrings.noBackToList.tr,
//                       style: TextStyles.headingBold.copyWith(fontSize: 16),textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       });
//   // return choosedImage;
// }
// Future removeMultipleWorker(BuildContext context, Function()? confirmOnTap,Function()? cancelOnTap) async {
//   await showModalBottomSheet(
//       backgroundColor: Get.theme.colorScheme.onPrimary,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(25.0),
//         ),
//       ),
//       context: context,
//       builder: (builder) {
//         return Container(
//           height: ScreenConstant.screenHeightThirdAndHalf,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(25.0),
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 28.0),
//               child: Column(
//                 children: [
//                   Gap(10),
//                   Container(
//                     width: 54,
//                     height: 3,
//                     decoration: ShapeDecoration(
//                       color: CustomColor.error,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     ),
//                   ),
//                   Container(height: ScreenConstant.defaultHeightTwentyThree,),
//                   Text(
//                     AppStrings.areYouSure.tr,
//                     style: TextStyles.headingBold.copyWith(fontSize: 16),textAlign: TextAlign.center,
//                   ),
//                   Container(height: ScreenConstant.defaultHeightFifteen,),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                         fixedSize: WidgetStateProperty.all<Size>(
//                           const Size(345.0, 48.0), // Set the desired width and height
//                         ),
//                         shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0), // Adjust the value as needed
//                           ),
//                         ),
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                             CustomColor.error)),
//                     onPressed: confirmOnTap,
//                     child: Text(AppStrings.confirm.tr,style: TextStyles.buttonText,),
//                   ),
//                   Container(height: ScreenConstant.defaultHeightTwentyThree,),
//                   InkWell(
//                     onTap: cancelOnTap,
//                     child: Text(
//                       AppStrings.noBackToList.tr,
//                       style: TextStyles.headingBold.copyWith(fontSize: 16),textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       });
//   // return choosedImage;
// }
// Map<String, String> getQrDialogLabels(Map<String, dynamic> taskJson) {
//   String type = taskJson['type'] ?? '';
//
//   switch (type) {
//     case "TaskAssignmentFromConductor":
//       return {"from": "Conductor", "to": "Assistant Manager", "Target" : "Need approval from Assistant Manager for Task"};
//     case "TaskApprovedByAssistantManager":
//       return {"from": "Assistant Manager", "to": "Estate Manager", "Target" : "Need approval from Estate Manager for Task"};
//     case "TaskApprovedByEstateManager":
//       return {"from": "Estate Manager", "to": "Conductor", "Target" : "Task approved. Ready to send it to the Conductor."};
//     case "TaskAssignmentFromConductorToFieldChecker":
//       return {"from": "Conductor", "to": "Field Checker", "Target" : "Task is ready for Grading chit's"};
//     case "DocketCreationWBOperater":
//       return {"from": "WB Operator", "to": "Truck", "Target" : "Transfer docket to Checker via Truck."};
//     case "GetDocketForApproval":
//       return {"from": "Field Checker", "to": "Conductor", "Target" : "Transfer docket for approval."};
//     case "ApprovedDocketToTheWBOperator":
//       return {"from": "Conductor", "to": "Truck", "Target" : "Transfer docket to WB operator for estate loaded weigh via truck."};
//     case "WBOperatorLoadedWeightFilledUp":
//       return {"from": "WB Operator Estate Loaded", "to": "Truck or WB Operator Mill Loaded or Mill Grader", "Target" : "Transfer docket from WB Operator Estate to WB Operator Mill or Mill Grader."};
//     case "MillGraderToFieldCheckerForGradingApproval":
//       return {"from": "Mill Loader", "to": "Field Checker", "Target" : "Transfer docket grading for approval."};
//     default:
//       return {"from": "Unknown", "to": "Unknown"};
//   }
// }
//
// Future OpenQrCodeDialog(BuildContext context, json, nameOfTask, totalNumberOfTask, indexOfTask, isForTask, isForDocket) async {
//   showModalBottomSheet(
//       shape:
//       RoundedRectangleBorder(
//         borderRadius:
//         BorderRadius.vertical(
//             top: Radius.circular(10.0)),
//       ),
//       backgroundColor:
//       Colors
//           .white,
//       context:
//       context,
//       builder:
//           (BuildContext
//       context) {
//             Map<String, String> labels = getQrDialogLabels(json);
//             String fromLabel = labels["from"] ?? "Unknown";
//             String toLabel = labels["to"] ?? "Unknown";
//             String targetLabel = labels["Target"] ?? "Unknown";
//         return Container(
//           height: ScreenConstant.screenHeightMoreThanHalf,
//           padding: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthTwenty,vertical: ScreenConstant.defaultHeightFifteen),
//           child: Column(children: [
//             isForDocket == false?Row(
//               children: [
//                 Text("Total number of task: ${totalNumberOfTask}",style: TextStyles.homeLight,),
//                 Spacer(),
//                 Text("App Version: ${Urls.appVer}",style: TextStyles.homeLight.copyWith(fontSize: 10, color: CustomColor.primaryBlack.withOpacity(0.6),),),
//               ],
//             ):Row(
//               children: [
//                 Text("Total number of docket: ${totalNumberOfTask}",style: TextStyles.homeLight,),
//                 Spacer(),
//                 Text("App Version: ${Urls.appVer}",style: TextStyles.homeLight.copyWith(fontSize: 10, color: CustomColor.primaryBlack.withOpacity(0.6),),),
//               ],
//             ),
//             Container(height: ScreenConstant.defaultHeightTen,),
//             Container(
//               alignment: Alignment.center,
//               child: RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: TextStyles.homeLight,
//                   children: [
//                     TextSpan(text: "From "),
//                     TextSpan(
//                       text: fromLabel,
//                       style: TextStyles.homeLight.copyWith(color: CustomColor.error),
//                     ),
//                     TextSpan(text: " to "),
//                     TextSpan(
//                       text: toLabel,
//                       style: TextStyles.homeLight.copyWith(color: CustomColor.error),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             Container(height: ScreenConstant.defaultHeightTen,),
//             RichText(
//               textAlign: TextAlign.center,
//               text: TextSpan(
//                 style: TextStyles.homeLight,
//                 children: [
//                   TextSpan(
//                     text: "Objective: ",
//                   ),
//                   TextSpan(
//                     text: targetLabel,
//                     style: TextStyles.homeLight.copyWith(color: CustomColor.error),
//                   ),
//                 ],
//               ),
//             ),
//
//
//             isForDocket == false?Container(height: ScreenConstant.defaultHeightTen,):Container(height: ScreenConstant.defaultHeightTen,),
//
//             isForDocket == false?Container(height: ScreenConstant.defaultHeightTen,):Container(height: ScreenConstant.defaultHeightTen,),
//             isForDocket == false? isForTask == true?Text("Name of Task: ${nameOfTask}",style: TextStyles.homeLight,textAlign: TextAlign.center,):Text("Name of Employee: ${nameOfTask}",style: TextStyles.homeLight,):Text("Name of Docket: ${nameOfTask}",style: TextStyles.homeLight,),
//             //Container(height: ScreenConstant.defaultHeightTen,),
//             isForDocket == false?Text("Current task index: ${indexOfTask+1}",style: TextStyles.homeLight,):Text("Current docket index: ${indexOfTask+1}",style: TextStyles.homeLight,),
//             RichText(
//               textAlign: TextAlign.center,
//               text: TextSpan(
//                 style: TextStyles.homeLight,
//                 children: [
//                   TextSpan(
//                     text: "QR generated on: ",
//                   ),
//                   TextSpan(
//                     text: DateFormat('hh:mm:ss a').format(DateTime.now()),
//                     style: TextStyles.homeLight.copyWith(color: CustomColor.error),
//                   ),
//                 ],
//               ),
//             ),
//           ],),
//         );
//       });
//
// }
//
// String formatPosition(String input) {
//   return input
//       .split('-')
//       .map((word) => word.isNotEmpty
//       ? word[0].toUpperCase() + word.substring(1).toLowerCase()
//       : '')
//       .join(' ');
// }
//
// String formatTitle(String input) {
//   switch (input) {
//     case 'loose-fruit-collector':
//       return 'Loose Fruit Collector';
//     case 'mill-grader':
//       return 'Mill Grader';
//     case 'acting-senior-manager':
//       return 'Estate Manager';
//     case 'manager':
//       return 'Estate Manager';
//     case 'officer-in-charge':
//       return 'Estate Manager';
//     case 'acting-manager':
//       return 'Estate Manager';
//     case 'assistant-manager':
//       return 'Assistant Manager';
//     case 'junior-assistant':
//       return 'Assistant Manager';
//     case 'executive':
//       return 'Assistant Manager';
//     case 'executive-field-operation':
//       return 'Assistant Manager';
//     case 'estate-manager':
//       return 'Estate Manager';
//     case 'conductor':
//       return 'Conductor';
//     case 'senior-conductor':
//       return 'Conductor';
//     case 'general-worker':
//       return 'General Worker';
//     case 'ramp-checker':
//       return 'Field Checker';
//     case'driver-farm-tractor':
//       return 'Driver Farm Tractor';
//     case 'field-checker':
//       return 'Field Checker';
//       //mill
//     case 'wb-operator-mill':
//       return 'Weighbridge Operator';
//       //mill
//     case 'weightbridge-clerk':
//       return 'Weighbridge Operator';
//
//       //mill
//     case 'general-clerk':
//       return 'Weighbridge Operator';
//       //mill
//     case 'administrative-clerk':
//       return 'Weighbridge Operator';
//       //estate
//     case 'weightbridge-attendant-estate':
//       return 'Weighbridge Operator';
//       //estate
//     case 'wb-operator-estate':
//       return 'Weighbridge Operator';
//     case 'farm-tractor-operator':
//       return 'Farm Tr Operator';
//     case 'harvester-mechanize':
//       return 'Harvester Mechanized';
//     case 'harvester-normal':
//       return 'Harvester Normal';
//     case 'harvester-immature':
//       return 'Harvester Immature';
//     case 'ffb-grader':
//       return 'Mill Grader';
//   // Add more cases as needed
//     default:
//       return 'General Worker'; // Return a default value if the input doesn't match any case
//   }
// }
//
// Future chooseCameraOrGalleryModalBottomSheetMenu(BuildContext context, Function onImageSelected,{bool? isFront = false}) async {
//   XFile? choosedImage;
//   await showModalBottomSheet(
//       backgroundColor: Get.theme.colorScheme.onPrimary,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(25.0),
//         ),
//       ),
//       context: context,
//       builder: (builder) {
//         return Container(
//           height: 187.0,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(25.0),
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 28.0),
//               child: Column(
//                 children: [
//                   Gap(10),
//                   Container(
//                     width: 54,
//                     height: 3,
//                     decoration: ShapeDecoration(
//                       color: CustomColor.buttonDarkColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     ),
//                   ),
//                   Gap(30),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                         fixedSize: WidgetStateProperty.all<Size>(
//                           const Size(335.0, 48.0), // Set the desired width and height
//                         ),
//                         shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0), // Adjust the value as needed
//                           ),
//                         ),
//                         backgroundColor: WidgetStateProperty.all<Color>(CustomColor.buttonDarkColor)),
//                     onPressed: () async {
//                       Get.back();
//                       debugPrint("Camera button pressed");
//                       choosedImage = await  openCamera(context,isFront: isFront);
//                       onImageSelected(choosedImage);
//                     },
//                     child: const Text("Take Photo",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 15,color: Colors.white),),
//                   ),
//                   Gap(14),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                         fixedSize: WidgetStateProperty.all<Size>(
//                           const Size(335.0, 48.0), // Set the desired width and height
//                         ),
//                         shape: WidgetStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0), // Adjust the value as needed
//                           ),
//                         ),
//                         backgroundColor: MaterialStateProperty.all<Color>(
//                             CustomColor.buttonDarkColor)),
//                     onPressed: () async {
//                       Get.back();
//                       debugPrint("Gallery button pressed");
//                       choosedImage = await _getFromGallery();
//                       print("Gallery:${choosedImage?.readAsBytes()}");
//                       onImageSelected(choosedImage);
//                     },
//                     child: const Text("Add Photo from library",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 15),),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       });
//   // return choosedImage;
// }
//
// Future<XFile?> openGallery(context) async {
//   // Check if the storage permission is already granted
//   PermissionStatus status = await Permission.storage.status;
//   if (status.isGranted) {
//     // Permission is already granted, open the gallery
//     return _getFromGallery();
//   } else if (status.isDenied) {
//     // Permission is denied, show a dialog to request permission again
//     showPermissionDialog(context);
//   } else {
//     // Permission is not determined, request the storage permission
//     PermissionStatus requestedStatus = await Permission.storage.request();
//     if (requestedStatus.isGranted) {
//       // Permission granted, open the gallery
//       return _getFromGallery();
//     } else if (requestedStatus.isPermanentlyDenied) {
//       // Permission denied permanently, show a dialog to redirect to app settings
//       showSettingsDialog(context);
//     } else {
//       // Permission denied, handle accordingly
//       print('Gallery permission denied');
//     }
//   }
// }
//
// Future<XFile?> openCamera(context,{bool? isFront = false}) async {
//   // Check if the camera permission is already granted
//   PermissionStatus status = await Permission.camera.status;
//   if (status.isGranted) {
//     // Permission is already granted, open the camera
//     return _getFromCamera(isFront: isFront);
//   } else if (status.isDenied) {
//     // Permission is denied, show a dialog to request permission again
//     showPermissionDialog(context);
//   } else {
//     // Permission is not determined, request the camera permission
//     PermissionStatus requestedStatus = await Permission.camera.request();
//     if (requestedStatus.isGranted) {
//       // Permission granted, open the camera
//       return _getFromCamera(isFront: isFront);
//     } else if (requestedStatus.isPermanentlyDenied) {
//       // Permission denied permanently, show a dialog to redirect to app settings
//       showSettingsDialog(context);
//     } else {
//       // Permission denied, handle accordingly
//       print('Camera permission denied');
//     }
//   }
// }
//
// void showSettingsDialog(context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Permission Required'),
//         content: const Text(
//             'Camera permission is required. Please enable it in the app settings.'),
//         actions: [
//           TextButton(
//             child: const Text('CANCEL'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: const Text('SETTINGS'),
//             onPressed: () {
//               Navigator.of(context).pop();
//               openAppSettings(); // Open app settings page
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
//
// void showPermissionDialog(context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Permission Required'),
//         content: const Text('This app requires access to the camera.'),
//         actions: [
//           TextButton(
//             child: const Text('CANCEL'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: const Text('SETTINGS'),
//             onPressed: () {
//               Navigator.of(context).pop();
//               openAppSettings(); // Open app settings page
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
//
// Future<XFile?> _getFromGallery() async {
//   XFile? selectedImage;
//   selectedImage = (await ImagePicker().pickImage(
//     source: ImageSource.gallery,
//     maxWidth: 1800,
//     maxHeight: 1800,
//   ));
//   return XFile(selectedImage!.path);
// }
//
// Future<XFile?> _getFromCamera({bool? isFront= false}) async {
//   print("ISFRONT:$isFront");
//   XFile? selectedImage;
//
//   // Pick image from the camera
//   selectedImage = await ImagePicker().pickImage(
//     source: ImageSource.camera,
//     preferredCameraDevice: (isFront ?? false)?CameraDevice.front:CameraDevice.rear,
//     maxWidth: 1800,
//     maxHeight: 1800,
//   );
//
//   // Check if an image was selected
//   // if (selectedImage != null) {
//   //   // Crop the selected image
//   //   CroppedFile? croppedImage = await ImageCropper().cropImage(
//   //     sourcePath: selectedImage.path,
//   //     aspectRatioPresets: [
//   //       CropAspectRatioPreset.square,
//   //       CropAspectRatioPreset.ratio3x2,
//   //       CropAspectRatioPreset.original,
//   //       CropAspectRatioPreset.ratio4x3,
//   //       CropAspectRatioPreset.ratio16x9,
//   //       CropAspectRatioPreset.ratio7x5,
//   //     ],
//   //     compressQuality: 100, // Set the compression quality
//   //   );
//   //
//   //   // Convert the File to XFile
//   //   if (croppedImage != null) {
//   //     return XFile(croppedImage.path);
//   //   }
//   // }
//
//   // Return null if no image was selected or cropping was canceled
//   return XFile(selectedImage!.path);
// }
//
// Future<bool> networkCheck() async {
//   try {
//     final result = await InternetAddress.lookup("google.com");
//     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//       return false;
//     } else {
//       return true;
//     }
//   } on SocketException catch (_) {
//     return true;
//   }
// }