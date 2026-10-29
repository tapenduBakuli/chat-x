import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        centerTitle: true,
        leading:  GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){Get.back();},
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        title: Text(
          "Notifications",
          textAlign: TextAlign.center,
          style: TextStyles.registerAppBarTitle,
        ),
        actions: [
          Text(
            "Mark all",
            style: TextStyles.registerSubtitle,
          ),
          SizedBox(width: ScreenConstant.defaultWidthTen,)
        ],
      ),
      body: Center(
        child: Text('This is the notifications screen.'),
      ),
    );
  }
}
