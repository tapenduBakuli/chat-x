import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/biometric_service.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Email entered on the Forgot Password screen.
  final TextEditingController forgotEmailController = TextEditingController();

  /// Whether a reset-link request is in progress.
  final RxBool isSendingReset = false.obs;

  /// Whether the password is currently hidden.
  final RxBool obscurePassword = true.obs;

  /// Whether "Remember me" is enabled.
  final RxBool rememberMe = false.obs;

  /// Whether a biometric authentication prompt is currently in progress.
  final RxBool isAuthenticating = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void onLoginTap() {
    // Hook up authentication here.
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    debugPrint(
      'Login tapped -> email: $email, '
      'password length: ${password.length}, remember: ${rememberMe.value}',
    );
  }

  /// Authenticates the user with the device's biometrics (Face ID / Touch ID /
  /// fingerprint). On success, routes to the app root.
  Future<void> onBiometricTap() async {
    if (isAuthenticating.value) return;
    isAuthenticating.value = true;

    try {
      final result = await BiometricService.authenticate(
        reason: 'Log in to ChatX with your biometrics',
      );

      if (result.success) {
        _onBiometricSuccess();
      } else {
        Get.snackbar(
          'Login failed',
          result.message ?? 'Biometric authentication failed.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isAuthenticating.value = false;
    }
  }

  void _onBiometricSuccess() {
    // TODO: load the saved session/token, then navigate to your home screen,
    // e.g. Get.offAllNamed(Routes.HOME). ROOT currently maps to the splash
    // screen, so navigation is intentionally left for you to wire to the
    // correct post-login destination.
    debugPrint('Biometric login succeeded');
    Get.snackbar(
      'Welcome back',
      'Biometric login successful.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onForgotPassword() {
    // Prefill the reset field with whatever was typed on the login form.
    forgotEmailController.text = emailController.text.trim();
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  /// Validates the email and (eventually) triggers the password-reset email.
  Future<void> onSendResetLink() async {
    if (isSendingReset.value) return;

    final email = forgotEmailController.text.trim();
    if (!_isValidEmail(email)) {
      Get.snackbar(
        'Invalid email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSendingReset.value = true;
    try {
      // TODO: call the backend reset-password endpoint here.
      debugPrint('Send reset link -> $email');
      Get.snackbar(
        'Check your inbox',
        "If an account exists for $email, we've sent a reset link.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingReset.value = false;
    }
  }

  void onBackToLogin() {
    Get.back();
  }

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return regex.hasMatch(email);
  }

  void onCreateAccount() {
    Get.toNamed(Routes.REGISTER);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    super.onClose();
  }
}
