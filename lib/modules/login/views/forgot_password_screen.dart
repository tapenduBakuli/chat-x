import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/login_controller.dart';

/// "Forgot your password?" screen — collects an email and triggers a reset
/// link. Styled to match the ChatX login card (white rounded card with a soft
/// shadow, rose envelope header, and the shared gradient action button).
class ForgotPasswordScreen extends GetView<LoginController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.defaultWidthTwenty,
              vertical: ScreenConstant.defaultHeightThirty,
            ),
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.defaultWidthTwenty,
        vertical: ScreenConstant.defaultHeightThirty,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: CustomColor.color717B96.withOpacity(0.4),
            blurRadius: 25.0,
            spreadRadius: -10.0,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderIcon(),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          Text(
            "Forgot your password?",
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s24),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          Text(
            "No worries! Enter your email and we'll send you a reset link.",
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcomeSubtitle,
          ),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          _buildEmailField(),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          Obx(
            () => buildLoginButton(
              controller.isSendingReset.value
                  ? "Sending..."
                  : "Send Verification Code",
              false,
              controller.isSendingReset.value
                  ? () {}
                  : controller.onSendResetLink,
              null,
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _buildBackToLogin(),
        ],
      ),
    );
  }

  // Rose envelope with a small key accent, mirroring the mock.
  Widget _buildHeaderIcon() {
    return SizedBox(
      height: ScreenConstant.defaultSizeEighty,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: ScreenConstant.texIconSize + 20,
            color: CustomColor.colorE11D48,
          ),
          Positioned(
            right: ScreenConstant.defaultWidthForty,
            top: 0,
            child: Text(
              "\u{1F511}", // 🔑
              style: TextStyle(fontSize: FontSize.s20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      height: ScreenConstant.defaultHeightSixty,
      child: CustomTextField(
        controller: controller.forgotEmailController,
        hintText: "Email",
        borderRadius: 100,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        borderColor: CustomColor.colorE2E8F0,
        fillColor: CustomColor.colorWhite,
        onChanged: (_) {},
        prefix: Icon(
          Icons.mail_outline,
          size: ScreenConstant.smallIconSize,
          color: CustomColor.color64748B,
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onBackToLogin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          Text(
            "Back to login",
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s16),
          ),
        ],
      ),
    );
  }
}
