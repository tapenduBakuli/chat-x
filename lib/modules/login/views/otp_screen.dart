import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../../../utils/lib/otp_text_field.dart';
import '../../../utils/lib/style.dart';
import '../controller/login_controller.dart';

/// Verification-code screen shown after the forgot-password request succeeds.
/// Collects a 4-digit OTP. Styled to match the login/forgot-password card
/// (white rounded card, soft shadow, rose→purple gradient action button).
class OtpScreen extends GetView<LoginController> {
  const OtpScreen({super.key});

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
            "Enter verification code",
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s24),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          Text(
            "We've sent a 4-digit code to\n${controller.otpEmail}",
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcomeSubtitle,
          ),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          _buildOtpBoxes(),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          _buildVerifyButton(),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _buildResendRow(),
          SizedBox(height: ScreenConstant.defaultHeightFifteen),
          _buildBackToLogin(),
        ],
      ),
    );
  }

  // Rose shield-lock header, echoing the forgot-password envelope treatment.
  Widget _buildHeaderIcon() {
    return SizedBox(
      height: ScreenConstant.defaultSizeEighty,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
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

  Widget _buildOtpBoxes() {
    return Center(
      child: OTPTextField(
        controller: controller.otpFieldController,
        length: LoginController.kOtpLength,
        width: Get.width,
        fieldWidth: ScreenConstant.defaultWidthSixty,
        spaceBetween: ScreenConstant.sizeMedium,
        textFieldAlignment: MainAxisAlignment.center,
        fieldStyle: FieldStyle.box,
        outlineBorderRadius: 16,
        keyboardType: TextInputType.number,
        inputFormatter: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s24),
        otpFieldStyle: OtpFieldStyle(
          backgroundColor: CustomColor.colorF8FAFC,
          borderColor: CustomColor.colorE2E8F0,
          enabledBorderColor: CustomColor.colorE2E8F0,
          focusBorderColor: CustomColor.colorDB2777,
          errorBorderColor: CustomColor.colorE11D48,
        ),
        onChanged: controller.onOtpChanged,
        onCompleted: controller.onOtpChanged,
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Obx(() {
      final bool busy = controller.isVerifyingOtp.value;
      final bool enabled = controller.isOtpComplete && !busy;
      if (busy) {
        return _loadingPill();
      }
      return Opacity(
        opacity: enabled ? 1 : 0.5,
        child: buildLoginButton(
          "Verify Code",
          false,
          enabled ? controller.onVerifyOtp : () {},
          null,
        ),
      );
    });
  }

  Widget _loadingPill() {
    return Container(
      height: ScreenConstant.defaultHeightSixty,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [CustomColor.colorBE185D, CustomColor.color581C87],
        ),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(CustomColor.colorWhite),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    return Obx(() {
      // Still counting down: show the timer, no action yet.
      if (!controller.canResendOtp) {
        final int s = controller.resendSeconds.value;
        final String mmss =
            "0:${s.toString().padLeft(2, '0')}";
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text(
              "Resend code in $mmss",
              style: TextStyles.loginWelcomeSubtitle,
            ),
          ],
        );
      }

      // Cooldown finished: show the resend action.
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Didn't get the code? ",
            style: TextStyles.loginWelcomeSubtitle,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.isResendingOtp.value
                ? null
                : controller.onResendOtp,
            child: Text(
              controller.isResendingOtp.value ? "Resending..." : "Resend code",
              style: TextStyles.loginForgotPassword.copyWith(
                fontSize: FontSize.s14,
              ),
            ),
          ),
        ],
      );
    });
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
