import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../device_manager/screen_constants.dart';
import '../TextStyles.dart';
import '../colors/app_colors.dart';

Widget buildLoginButton(String? text, bool prefixButtonEnabled, Function() onTap, IconData? prefixIcon) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: ScreenConstant.defaultHeightSixty,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            CustomColor.colorBE185D,
            CustomColor.color581C87,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColor.colorDB2777.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text ?? "Log in", style: TextStyles.loginButtonText),
          SizedBox(width: ScreenConstant.sizeSmall),
          prefixButtonEnabled? Icon(
            prefixIcon??Icons.arrow_forward,
            color: CustomColor.colorWhite,
            size: ScreenConstant.smallIconSize,
          ):const Offstage(),
        ],
      ),
    ),
  );
}