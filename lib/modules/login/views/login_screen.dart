import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:chat_x/utils/image_utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-apply remembered credentials whenever the login screen is shown
    // (e.g. after returning from the password-reset flow). Deferred to after
    // the frame so we never mutate controllers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadRememberedCredentials();
    });
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              Container(
                margin: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthTwenty),
                decoration: BoxDecoration(boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: CustomColor.color717B96.withOpacity(0.4),
                      blurRadius: 25.0,
                    spreadRadius: -10.0,
                    offset: const Offset(0, 18),
                  )
                ] ,color: CustomColor.colorWhite,borderRadius: BorderRadius.all(Radius.circular(20),)),
                padding: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthTwenty,vertical: ScreenConstant.defaultHeightTwentyThree),
                child: Column(
                  children: [
                    _buildBrand(),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                    _buildWelcome(),
                    SizedBox(height: ScreenConstant.defaultHeightTen),
                    _buildWelcomeSubtitle(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildEmailField(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildPasswordField(),
                    SizedBox(height: ScreenConstant.defaultHeightFifteen),
                    _buildRememberRow(),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                    SizedBox(height:ScreenConstant.defaultHeightFifty,child: _buildLoginButton()),
                    SizedBox(height: ScreenConstant.defaultHeightFifteen),
                    SizedBox(height:ScreenConstant.defaultHeightFifty,child: _buildBiometricButton()),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                    _buildFooter(controller.onCreateAccount),
                  ],
                ),
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top bar: CHATX ENCRYPTED  ................................  🔒 PRIVATE
  // ---------------------------------------------------------------------------
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeLarge,
        vertical: ScreenConstant.sizeSmall,
      ),
      child: Row(
        children: [
          Image.asset(
            ImageUtils.chatxEncryptedLogo,
            height: ScreenConstant.defaultHeightFifteen,
            errorBuilder: (_, __, ___) => Icon(
              Icons.shield_outlined,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color0F172A,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text("CHATX ENCRYPTED", style: TextStyles.loginTopText),
          const Spacer(),
          Container(height:ScreenConstant.defaultHeightFifteen-5, width: ScreenConstant.defaultWidthTen-3, decoration: BoxDecoration(shape: BoxShape.circle,color: CustomColor.color10B981),),
          SizedBox(width: ScreenConstant.sizeExtraSmall / 1),
          Text("PRIVATE", style: TextStyles.loginTopText),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Heart logo + "ChatX  PRIVATE"
  // ---------------------------------------------------------------------------
  Widget _buildBrand() {
    return Column(
      children: [
        Image.asset(
          ImageUtils.loginChatxTopLogo,
          height: ScreenConstant.defaultHeightSixty,
          width: ScreenConstant.defaultWidthSixty,
          errorBuilder: (_, __, ___) => Icon(
            Icons.favorite,
            color: CustomColor.colorWhite,
            size: ScreenConstant.texIconSize,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ChatX", style: TextStyles.loginBrand),
            SizedBox(width: ScreenConstant.sizeDefault),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeSmall,
                vertical: ScreenConstant.sizeExtraSmall / 1.5,
              ),
              decoration: BoxDecoration(
                color: CustomColor.colorFFF5F8,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text("PRIVATE", style: TextStyles.loginPrivateBadge),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildWelcome() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Welcome", style: TextStyles.loginWelcome),
        SizedBox(width: ScreenConstant.sizeDefault),
        Image.asset(
          ImageUtils.waveHandLogo,
          height: ScreenConstant.texIconSize,
          errorBuilder: (_, __, ___) =>
              Text("👋", style: TextStyles.loginWelcome),
        ),
      ],
    );
  }

  Widget _buildWelcomeSubtitle() {
    return Text(
      "Sign in to continue your discreet connections",
      textAlign: TextAlign.center,
      style: TextStyles.loginWelcomeSubtitle,
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email address", style: TextStyles.loginFieldLabel),
        SizedBox(height: ScreenConstant.sizeSmall),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            controller: controller.emailController,
            hintText: "ve001@chatx.be",
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            borderRadius: 26,
            prefix: Image.asset(
              ImageUtils.loginEmail,
              height: ScreenConstant.minimumIconSize,
              width: ScreenConstant.minimumIconSize,
              errorBuilder: (_, __, ___) => Icon(
                Icons.alternate_email,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color64748B,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password", style: TextStyles.loginFieldLabel),
        SizedBox(height: ScreenConstant.sizeSmall),
        Obx(
          () => SizedBox(
            height: ScreenConstant.defaultHeightFifty,
            child: CustomTextField(
              controller: controller.passwordController,
              hintText: "Test@123456",
              borderRadius: 26,
              hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              prefix: Image.asset(
                ImageUtils.loginPassPrefixLogo,
                height: ScreenConstant.minimumIconSize,
                width: ScreenConstant.minimumIconSize,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.lock_outline,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.color64748B,
                ),
              ),
              suffix: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: controller.obscurePassword.value
                    ? Image.asset(
                        ImageUtils.loginPassSuffixLogo,
                  color: CustomColor.color94A3B8,
                  height: ScreenConstant.minimumIconSize,
                  width: ScreenConstant.minimumIconSize,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.visibility_off_outlined,
                          size: ScreenConstant.smallIconSize,
                          color: CustomColor.color94A3B8,
                        ),
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        size: ScreenConstant.minimumIconSize,
                        color: CustomColor.color94A3B8,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Remember me (tappable toggle)  ...............  Forgot password?
  // ---------------------------------------------------------------------------
  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.toggleRememberMe,
          child: Row(
            children: [
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: ScreenConstant.minimumIconSize,
                  width: ScreenConstant.minimumIconSize,
                  decoration: BoxDecoration(
                    color: controller.rememberMe.value
                        ? CustomColor.colorDB2777
                        : CustomColor.colorWhite,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: controller.rememberMe.value
                          ? CustomColor.colorDB2777
                          : CustomColor.color64748B,
                      width: 1.5,
                    ),
                  ),
                  child: controller.rememberMe.value
                      ? Icon(
                          Icons.check,
                          size: ScreenConstant.minimumIconSize - 2,
                          color: CustomColor.colorWhite,
                        )
                      : null,
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Text("Remember me", style: TextStyles.loginRememberMe),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onForgotPassword,
          child: Text(
            "Forgot password?",
            style: TextStyles.loginForgotPassword,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------


  // ---------------------------------------------------------------------------
  // Login button: shows a spinner inside the gradient pill while a login
  // request is in flight.
  Widget _buildLoginButton() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
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
      return buildLoginButton("Login", true, controller.onLoginTap, null);
    });
  }

  // ---------------------------------------------------------------------------
  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: controller.onBiometricTap,
      child: Container(
        height: ScreenConstant.defaultHeightSixty,
        decoration: BoxDecoration(
          color: CustomColor.colorF8FAFC,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              color: CustomColor.color334155,
              size: ScreenConstant.smallIconSize,
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Text(
              "Quick Face ID / Biometric Log In",
              style: TextStyles.loginBiometricText,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildFooter(Function() onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("New to ChatX? ", style: TextStyles.loginFooterText),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Text("Create an account", style: TextStyles.loginFooterLink),
        ),
      ],
    );
  }
}
