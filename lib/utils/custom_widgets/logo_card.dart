import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../device_manager/screen_constants.dart';
import '../colors/app_colors.dart';

class LogoCard extends StatelessWidget {
  const LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenConstant.defaultWidthOneSixty,
      height: ScreenConstant.defaultHeightNinetyFive,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color581C87.withOpacity(0.12),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Container(
        padding: ScreenConstant.spacingAllExtraSmall,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset(
          'assets/images/chatxlogo.png',
          height: 44,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}