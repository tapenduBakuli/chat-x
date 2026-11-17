import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/login/controller/login_controller.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:chat_x/utils/TextStyles.dart';
import 'package:chat_x/utils/colors/app_colors.dart';
import 'package:chat_x/utils/custom_widgets/universal_button.dart';
import 'package:chat_x/utils/lib/otp_text_field.dart';
import 'package:chat_x/utils/lib/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Displays the registration email verification OTP bottom sheet.
void showRegistrationOtpSheet(BuildContext context, String email) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: CustomColor.colorWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: RegistrationOtpSheet(email: email),
      );
    },
  );
}

class RegistrationOtpSheet extends StatelessWidget {
  final String email;

  const RegistrationOtpSheet({super.key, required this.email});

  RegisterController get controller => Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          ScreenConstant.defaultWidthTwenty,
          ScreenConstant.sizeMedium,
          ScreenConstant.defaultWidthTwenty,
          ScreenConstant.sizeLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.colorBE185D,
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(
                  child: Text(
                    "Verify Email",
                    style: TextStyles.registerSectionTitle.copyWith(
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Center(
              child: Text(
                "We've sent a verification code to\n$email",
                textAlign: TextAlign.center,
                style: TextStyles.loginWelcomeSubtitle.copyWith(
                  fontSize: FontSize.s13,
                ),
              ),
            ),
            SizedBox(height: ScreenConstant.sizeLarge),

            // OTP Box Inputs
            Center(
              child: OTPTextField(
                controller: controller.registrationOtpFieldController,
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
                onChanged: (pin) {
                  controller.registrationOtpCode.value = pin;
                },
                onCompleted: (pin) {
                  controller.registrationOtpCode.value = pin;
                },
              ),
            ),
            SizedBox(height: ScreenConstant.sizeLarge),

            // Verify & Continue Button
            Obx(() {
              final bool busy = controller.isVerifyingOtp.value;
              final bool canVerify =
                  controller.registrationOtpCode.value.trim().length >= 4 &&
                      !busy;
              if (busy) {
                return Container(
                  height: ScreenConstant.defaultHeightFifty,
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
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(CustomColor.colorWhite),
                    ),
                  ),
                );
              }
              return buildLoginButton(
                "Verify & Continue",
                canVerify,
                canVerify
                    ? () => controller.verifyRegistrationOtp(context, email)
                    : () {},
                Icons.arrow_forward,
                height: ScreenConstant.defaultHeightFifty,
                fontSize: FontSize.s14,
                iconSize: ScreenConstant.minimumIconSize,
              );
            }),
            SizedBox(height: ScreenConstant.sizeMedium),

            // Resend Code Row with Countdown Timer
            Obx(() {
              if (!controller.canResendOtp) {
                final int s = controller.otpResendSeconds.value;
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
                    onTap: controller.isSendingOtp.value
                        ? null
                        : () => controller.sendRegistrationOtp(email),
                    child: Text(
                      controller.isSendingOtp.value
                          ? "Resending..."
                          : "Resend code",
                      style: TextStyles.loginForgotPassword.copyWith(
                        fontSize: FontSize.s14,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
