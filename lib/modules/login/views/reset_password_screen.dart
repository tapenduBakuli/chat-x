import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/login_controller.dart';

/// Shown after the OTP is verified. Collects a new password (with the same
/// strength requirements as the Create-account flow) and a confirmation.
/// "Back" returns to the Forgot Password screen (not the OTP screen).
class ResetPasswordScreen extends GetView<LoginController> {
  const ResetPasswordScreen({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderIcon(),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          Text(
            "Reset Password",
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s24),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          Text(
            "Create a strong new password for your account",
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcomeSubtitle,
          ),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          _buildVerifiedBanner(),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _buildNewPasswordField(),
          _buildStrength(),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _buildConfirmField(),
          _buildMatchStatus(),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          _buildActionRow(),
        ],
      ),
    );
  }

  // Open-lock rose header, matching the mock.
  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        height: ScreenConstant.defaultSizeEighty,
        width: ScreenConstant.defaultSizeEighty,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColor.colorFFF1F2,
        ),
        child: Icon(
          Icons.lock_open_outlined,
          size: ScreenConstant.texIconSize,
          color: CustomColor.colorBE123C,
        ),
      ),
    );
  }

  Widget _buildVerifiedBanner() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorECFDF5,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColor.color10B981.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color059669,
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          Expanded(
            child: Text(
              "Email verified. Set your new password below.",
              style: TextStyles.registerFieldNote.copyWith(
                color: CustomColor.color059669,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Obx(
      () => SizedBox(
        height: ScreenConstant.defaultHeightSixty,
        child: CustomTextField(
          borderRadius: 100,
          controller: controller.newPasswordController,
          hintText: "New Password",
          hintStyle:
              TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
          obscureText: controller.obscureNewPassword.value,
          textInputAction: TextInputAction.next,
          borderColor: CustomColor.colorE2E8F0,
          fillColor: CustomColor.colorWhite,
          prefix: Icon(
            Icons.lock_outline,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color64748B,
          ),
          suffix: GestureDetector(
            onTap: controller.toggleNewPasswordVisibility,
            child: Icon(
              controller.obscureNewPassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: ScreenConstant.smallIconSize,
              color: CustomColor.color94A3B8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmField() {
    return Obx(
      () => SizedBox(
        height: ScreenConstant.defaultHeightSixty,
        child: CustomTextField(
          borderRadius: 100,
          controller: controller.confirmNewPasswordController,
          hintText: "Confirm New Password",
          hintStyle:
              TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
          obscureText: controller.obscureConfirmNewPassword.value,
          textInputAction: TextInputAction.done,
          borderColor: CustomColor.colorE2E8F0,
          fillColor: CustomColor.colorWhite,
          prefix: Icon(
            Icons.lock_outline,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color64748B,
          ),
          suffix: GestureDetector(
            onTap: controller.toggleConfirmNewPasswordVisibility,
            child: Icon(
              controller.obscureConfirmNewPassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: ScreenConstant.smallIconSize,
              color: CustomColor.color94A3B8,
            ),
          ),
        ),
      ),
    );
  }

  // Strength meter + rule checklist (mirrors the register password field).
  Widget _buildStrength() {
    return Obx(() {
      if (controller.newPassword.value.isEmpty) {
        return const SizedBox.shrink();
      }
      final int score = controller.passwordScore;
      final Color strengthColor = _strengthColor(score);
      return Padding(
        padding: EdgeInsets.only(top: ScreenConstant.sizeSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.passwordError.isNotEmpty) ...[
              Text(
                controller.passwordError,
                style: TextStyles.registerFieldNote.copyWith(
                  color: CustomColor.colorE11D48,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeSmall),
            ],
            Row(
              children: List.generate(4, (i) {
                final bool filled = i < score;
                return Expanded(
                  child: Container(
                    height: 5,
                    margin: EdgeInsets.only(
                      right: i < 3 ? ScreenConstant.sizeExtraSmall : 0,
                    ),
                    decoration: BoxDecoration(
                      color: filled ? strengthColor : CustomColor.colorE2E8F0,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              controller.passwordStrengthLabel,
              style: TextStyles.registerFieldLabel.copyWith(
                color: strengthColor,
              ),
            ),
            SizedBox(height: ScreenConstant.sizeSmall),
            _rule("At least 10 characters", controller.hasMinLength),
            _rule("One uppercase letter", controller.hasUppercase),
            _rule("One lowercase letter", controller.hasLowercase),
            _rule("One number", controller.hasNumber),
          ],
        ),
      );
    });
  }

  Widget _buildMatchStatus() {
    return Obx(() {
      if (controller.confirmNewPassword.value.isEmpty) {
        return const SizedBox.shrink();
      }
      final bool matches = controller.newPasswordsMatch;
      return Padding(
        padding: EdgeInsets.only(top: ScreenConstant.sizeSmall),
        child: Row(
          children: [
            Icon(
              matches ? Icons.check_circle_outline : Icons.error_outline,
              size: ScreenConstant.minimumIconSize,
              color:
                  matches ? CustomColor.color059669 : CustomColor.colorE11D48,
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Text(
              matches ? "Passwords match" : "Passwords do not match",
              style: TextStyles.registerFieldNote.copyWith(
                color:
                    matches ? CustomColor.color059669 : CustomColor.colorE11D48,
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _strengthColor(int score) {
    switch (score) {
      case 0:
      case 1:
        return CustomColor.colorBE123C;
      case 2:
        return CustomColor.colorD97706;
      case 3:
        return CustomColor.colorBE185D;
      default:
        return CustomColor.color059669;
    }
  }

  Widget _rule(String label, bool satisfied) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: ScreenConstant.sizeExtraSmall / 2),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check : Icons.close,
            size: ScreenConstant.minimumIconSize,
            color:
                satisfied ? CustomColor.color059669 : CustomColor.color94A3B8,
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          Text(
            label,
            style: TextStyles.registerFieldNote.copyWith(
              color: satisfied
                  ? CustomColor.color059669
                  : CustomColor.color64748B,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        // Back → Forgot Password.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBackFromReset,
          child: Container(
            height: ScreenConstant.defaultHeightFifty,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.defaultWidthTwenty,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CustomColor.colorWhite,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
            ),
            child: Text(
              "Back",
              style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s16),
            ),
          ),
        ),
        SizedBox(width: ScreenConstant.sizeMedium),
        Expanded(
          child: Obx(() {
            if (controller.isResettingPassword.value) {
              return _loadingPill();
            }
            return buildLoginButton(
              "Reset Password",
              false,
              controller.onResetPassword,
              null,
            );
          }),
        ),
      ],
    );
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
}
