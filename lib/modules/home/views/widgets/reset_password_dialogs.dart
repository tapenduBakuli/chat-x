import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../../../utils/custom_text_field.dart';
import '../../../../utils/custom_widgets/universal_button.dart';
import '../../../../utils/lib/otp_text_field.dart';
import '../../../../utils/lib/style.dart';
import '../../../login/services/login_services.dart';
import '../../controller/home_controller.dart';

/// The three standalone reset-password dialogs used by the Accounts tab's
/// "Change Password / Forgot Password" action: email → OTP → new password.
///
/// They reuse [LoginService] (sendOtp / verifyEmail / resetPassword) and read
/// their state from [HomeController] (GetX consistency), so no network code is
/// duplicated and all controllers/timers dispose cleanly in onClose.

// ---------------------------------------------------------------------------
// (1) Email dialog
// ---------------------------------------------------------------------------
void showResetEmailDialog(BuildContext context, HomeController c) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _dialogShell(
        headerIcon: Icons.lock_outline,
        title: "Reset Password",
        subtitle: "Enter your email and we'll send a 4-digit code.",
        children: [
          SizedBox(
            height: ScreenConstant.defaultHeightSixty,
            child: CustomTextField(
              borderRadius: 100,
              controller: c.resetEmailController,
              hintText: "Email address",
              hintStyle: TextStyles.loginTopText.copyWith(
                fontSize: FontSize.s14,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              borderColor: CustomColor.colorE2E8F0,
              fillColor: CustomColor.colorWhite,
              prefix: Icon(
                Icons.mail_outline,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color64748B,
              ),
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          Obx(() {
            if (c.isSendingResetOtp.value) return _loadingPill();
            return buildLoginButton(
              "Send Code",
              false,
              () => _onSendCode(dialogContext, c),
              null,
              height: ScreenConstant.defaultHeightFifty,
              fontSize: FontSize.s14,
            );
          }),
        ],
      );
    },
  );
}

Future<void> _onSendCode(BuildContext dialogContext, HomeController c) async {
  if (c.isSendingResetOtp.value) return;
  final email = c.resetEmailController.text.trim();
  if (!c.isValidResetEmail(email)) {
    Get.snackbar(
      'Invalid email',
      'Please enter a valid email address.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  c.isSendingResetOtp.value = true;
  try {
    final res = await LoginService.instance.sendOtp(email: email);
    if (res.success) {
      c.resetOtpCode.value = '';
      c.startResetResendTimer();
      Navigator.pop(dialogContext);
      showResetOtpDialog(Get.context ?? dialogContext, c);
    } else {
      Get.snackbar(
        'Could not send code',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    c.isSendingResetOtp.value = false;
  }
}

// ---------------------------------------------------------------------------
// (2) OTP dialog
// ---------------------------------------------------------------------------
void showResetOtpDialog(BuildContext context, HomeController c) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _dialogShell(
        headerIcon: Icons.verified_user_outlined,
        title: "Enter verification code",
        subtitle:
            "We've sent a 4-digit code to\n${c.resetEmailController.text.trim()}",
        children: [
          Center(
            child: OTPTextField(
              controller: c.resetOtpController,
              length: 4,
              width: Get.width,
              fieldWidth: ScreenConstant.defaultWidthFifty,
              spaceBetween: ScreenConstant.sizeSmall,
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
              onChanged: c.onResetOtpChanged,
              onCompleted: c.onResetOtpChanged,
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          Obx(() {
            final bool busy = c.isVerifyingResetOtp.value;
            final bool enabled = c.isResetOtpComplete && !busy;
            if (busy) return _loadingPill();
            return Opacity(
              opacity: enabled ? 1 : 0.5,
              child: buildLoginButton(
                "Verify",
                false,
                enabled ? () => _onVerifyOtp(dialogContext, c) : () {},
                null,
                height: ScreenConstant.defaultHeightFifty,
                fontSize: FontSize.s14,
              ),
            );
          }),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _buildResendRow(c),
        ],
      );
    },
  );
}

Future<void> _onVerifyOtp(BuildContext dialogContext, HomeController c) async {
  if (c.isVerifyingResetOtp.value) return;
  if (!c.isResetOtpComplete) {
    Get.snackbar(
      'Incomplete code',
      'Please enter all 4 digits.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  c.isVerifyingResetOtp.value = true;
  try {
    final res = await LoginService.instance.verifyEmail(
      email: c.resetEmailController.text.trim(),
      otp: c.resetOtpCode.value,
    );
    if (res.success) {
      c.resetToken.value = res.data?.resetToken ?? '';
      Navigator.pop(dialogContext);
      showResetNewPasswordDialog(Get.context ?? dialogContext, c);
    } else {
      Get.snackbar(
        'Verification failed',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    c.isVerifyingResetOtp.value = false;
  }
}

Widget _buildResendRow(HomeController c) {
  return Obx(() {
    if (!c.canResendResetOtp) {
      final int s = c.resetResendSeconds.value;
      final String mmss = "0:${s.toString().padLeft(2, '0')}";
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't get the code? ",
          style: TextStyles.loginWelcomeSubtitle,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.isResendingResetOtp.value ? null : () => _onResend(c),
          child: Text(
            c.isResendingResetOtp.value ? "Resending..." : "Resend code",
            style: TextStyles.loginForgotPassword.copyWith(
              fontSize: FontSize.s14,
            ),
          ),
        ),
      ],
    );
  });
}

Future<void> _onResend(HomeController c) async {
  if (c.isResendingResetOtp.value || !c.canResendResetOtp) return;
  c.isResendingResetOtp.value = true;
  try {
    final res = await LoginService.instance.sendOtp(
      email: c.resetEmailController.text.trim(),
    );
    if (res.success) {
      c.resetOtpCode.value = '';
      try {
        c.resetOtpController.clear();
      } catch (_) {}
      c.startResetResendTimer();
      Get.snackbar(
        'Code resent',
        res.message.isNotEmpty ? res.message : 'A new code has been sent.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Could not resend',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    c.isResendingResetOtp.value = false;
  }
}

// ---------------------------------------------------------------------------
// (3) New-password dialog
// ---------------------------------------------------------------------------
void showResetNewPasswordDialog(BuildContext context, HomeController c) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _dialogShell(
        headerIcon: Icons.lock_open_outlined,
        title: "Set New Password",
        subtitle: "Create a strong new password for your account.",
        children: [
          Obx(
            () => SizedBox(
              height: ScreenConstant.defaultHeightSixty,
              child: CustomTextField(
                borderRadius: 100,
                controller: c.resetNewPasswordController,
                hintText: "New Password",
                hintStyle: TextStyles.loginTopText.copyWith(
                  fontSize: FontSize.s14,
                ),
                obscureText: c.obscureResetNew.value,
                textInputAction: TextInputAction.next,
                borderColor: CustomColor.colorE2E8F0,
                fillColor: CustomColor.colorWhite,
                prefix: Icon(
                  Icons.lock_outline,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.color64748B,
                ),
                suffix: GestureDetector(
                  onTap: c.toggleObscureResetNew,
                  child: Icon(
                    c.obscureResetNew.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color94A3B8,
                  ),
                ),
              ),
            ),
          ),
          _buildStrength(c),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          Obx(
            () => SizedBox(
              height: ScreenConstant.defaultHeightSixty,
              child: CustomTextField(
                borderRadius: 100,
                controller: c.resetConfirmPasswordController,
                hintText: "Confirm New Password",
                hintStyle: TextStyles.loginTopText.copyWith(
                  fontSize: FontSize.s14,
                ),
                obscureText: c.obscureResetConfirm.value,
                textInputAction: TextInputAction.done,
                borderColor: CustomColor.colorE2E8F0,
                fillColor: CustomColor.colorWhite,
                prefix: Icon(
                  Icons.lock_outline,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.color64748B,
                ),
                suffix: GestureDetector(
                  onTap: c.toggleObscureResetConfirm,
                  child: Icon(
                    c.obscureResetConfirm.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color94A3B8,
                  ),
                ),
              ),
            ),
          ),
          _buildMatchStatus(c),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          Obx(() {
            if (c.isResettingPassword.value) return _loadingPill();
            return buildLoginButton(
              "Reset Password",
              false,
              () => _onResetPassword(dialogContext, c),
              null,
              height: ScreenConstant.defaultHeightFifty,
              fontSize: FontSize.s14,
            );
          }),
        ],
      );
    },
  );
}

Future<void> _onResetPassword(
  BuildContext dialogContext,
  HomeController c,
) async {
  if (c.isResettingPassword.value) return;
  if (!c.isResetPasswordValid) {
    Get.snackbar(
      'Weak password',
      'Password must be at least 10 characters with an uppercase letter, '
          'a lowercase letter, and a number.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }
  if (!c.resetPasswordsMatch) {
    Get.snackbar(
      'Passwords do not match',
      'Please make sure both passwords are identical.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  c.isResettingPassword.value = true;
  try {
    final res = await LoginService.instance.resetPassword(
      resetToken: c.resetToken.value,
      newPassword: c.resetNewPassword.value,
      confirmNewPassword: c.resetConfirmPassword.value,
    );
    if (res.success) {
      Navigator.pop(dialogContext);
      c.clearResetFlow();
      Get.snackbar(
        'Password updated',
        res.message.isNotEmpty
            ? res.message
            : 'Your password has been reset.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Could not reset password',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    c.isResettingPassword.value = false;
  }
}

// Strength rule checklist (mirrors reset_password_screen).
Widget _buildStrength(HomeController c) {
  return Obx(() {
    if (c.resetNewPassword.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: ScreenConstant.sizeSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rule("At least 10 characters", c.hasMinLength),
          _rule("One uppercase letter", c.hasUppercase),
          _rule("One lowercase letter", c.hasLowercase),
          _rule("One number", c.hasNumber),
        ],
      ),
    );
  });
}

Widget _buildMatchStatus(HomeController c) {
  return Obx(() {
    if (c.resetConfirmPassword.value.isEmpty) return const SizedBox.shrink();
    final bool matches = c.resetPasswordsMatch;
    return Padding(
      padding: EdgeInsets.only(top: ScreenConstant.sizeSmall),
      child: Row(
        children: [
          Icon(
            matches ? Icons.check_circle_outline : Icons.error_outline,
            size: ScreenConstant.minimumIconSize,
            color: matches ? CustomColor.color059669 : CustomColor.colorE11D48,
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

Widget _rule(String label, bool satisfied) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenConstant.sizeExtraSmall / 2),
    child: Row(
      children: [
        Icon(
          satisfied ? Icons.check : Icons.close,
          size: ScreenConstant.minimumIconSize,
          color: satisfied ? CustomColor.color059669 : CustomColor.color94A3B8,
        ),
        SizedBox(width: ScreenConstant.sizeSmall),
        Text(
          label,
          style: TextStyles.registerFieldNote.copyWith(
            color:
                satisfied ? CustomColor.color059669 : CustomColor.color64748B,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared dialog shell + loading pill
// ---------------------------------------------------------------------------

/// A consistent white rounded dialog card with a rose circular header icon,
/// title and subtitle, followed by [children].
Widget _dialogShell({
  required IconData headerIcon,
  required String title,
  required String subtitle,
  required List<Widget> children,
}) {
  return Dialog(
    backgroundColor: CustomColor.colorWhite,
    insetPadding: EdgeInsets.symmetric(
      horizontal: ScreenConstant.defaultWidthTwenty,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.defaultWidthTwenty,
        vertical: ScreenConstant.defaultHeightThirty,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              height: ScreenConstant.defaultSizeEighty,
              width: ScreenConstant.defaultSizeEighty,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColor.colorFFF1F2,
              ),
              child: Icon(
                headerIcon,
                size: ScreenConstant.texIconSize,
                color: CustomColor.colorBE123C,
              ),
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s20),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyles.loginWelcomeSubtitle,
          ),
          SizedBox(height: ScreenConstant.defaultHeightThirty),
          ...children,
        ],
      ),
    ),
  );
}

Widget _loadingPill() {
  return Container(
    height: ScreenConstant.defaultHeightFifty,
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
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(CustomColor.colorWhite),
      ),
    ),
  );
}
