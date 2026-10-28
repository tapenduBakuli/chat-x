import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../device_manager/screen_constants.dart';
import '../TextStyles.dart';
import '../colors/app_colors.dart';

/// Shared gradient (rose→purple) pill button.
///
/// Sizing is optional so the same button can be a full-size primary CTA
/// (defaults) or a smaller/compact action. Omit the size params to keep the
/// original look; pass [height]/[fontSize]/[horizontalPadding] to shrink it.
Widget buildLoginButton(
  String? text,
  bool prefixButtonEnabled,
  Function() onTap,
  IconData? prefixIcon, {
  double? height,
  double? fontSize,
  double? horizontalPadding,
  double? iconSize,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height ?? ScreenConstant.defaultHeightSixty,
      padding: horizontalPadding == null
          ? null
          : EdgeInsets.symmetric(horizontal: horizontalPadding),
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
          Text(
            text ?? "Log in",
            style: fontSize == null
                ? TextStyles.loginButtonText
                : TextStyles.loginButtonText.copyWith(fontSize: fontSize),
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          prefixButtonEnabled? Icon(
            prefixIcon??Icons.arrow_forward,
            color: CustomColor.colorWhite,
            size: iconSize ?? ScreenConstant.smallIconSize,
          ):const Offstage(),
        ],
      ),
    ),
  );
}