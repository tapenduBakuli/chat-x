import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';
import '../../../utils/biometric_service.dart';
import '../../../utils/lib/otp_text_field.dart';
import '../model/login_response_model.dart';
import '../services/login_services.dart';

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

  /// Whether a login request is in flight (drives the button spinner).
  final RxBool isLoading = false.obs;

  /// Whether a biometric authentication prompt is currently in progress.
  final RxBool isAuthenticating = false.obs;

  // --- OTP (password reset verification) ----------------------------------
  /// Number of OTP digits.
  static const int kOtpLength = 4;

  /// Controller for the OTPTextField widget (used to clear the fields).
  final OtpFieldController otpFieldController = OtpFieldController();

  /// Reactive concatenation of the entered digits (drives button enablement).
  final RxString otpCode = ''.obs;

  /// Whether an OTP verification request is in flight.
  final RxBool isVerifyingOtp = false.obs;

  /// Whether a resend-code request is in flight.
  final RxBool isResendingOtp = false.obs;

  /// Seconds left before "Resend code" becomes available. When > 0 the UI
  /// shows the countdown; at 0 it shows the Resend action.
  static const int kResendCooldown = 60;
  final RxInt resendSeconds = 0.obs;
  Timer? _resendTimer;

  bool get canResendOtp => resendSeconds.value == 0;

  // --- Reset password ------------------------------------------------------
  /// Token returned by verify-email; required to set the new password.
  final RxString resetToken = ''.obs;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmNewPassword = true.obs;

  /// Live mirrors of the two reset fields (drive the strength UI).
  final RxString newPassword = ''.obs;
  final RxString confirmNewPassword = ''.obs;

  final RxBool isResettingPassword = false.obs;

  /// Minimum required password length (mirrors the register flow).
  static const int kMinPasswordLength = 10;

  bool get hasMinLength => newPassword.value.length >= kMinPasswordLength;
  bool get hasUppercase => newPassword.value.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => newPassword.value.contains(RegExp(r'[a-z]'));
  bool get hasNumber => newPassword.value.contains(RegExp(r'[0-9]'));

  int get passwordScore => [
        hasMinLength,
        hasUppercase,
        hasLowercase,
        hasNumber,
      ].where((ok) => ok).length;

  bool get isNewPasswordValid => passwordScore == 4;

  String get passwordStrengthLabel {
    if (newPassword.value.isEmpty) return '';
    switch (passwordScore) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  String get passwordError {
    if (newPassword.value.isEmpty) return '';
    if (!hasMinLength) {
      return 'Password must be at least $kMinPasswordLength characters';
    }
    if (!hasUppercase) return 'Add at least one uppercase letter';
    if (!hasLowercase) return 'Add at least one lowercase letter';
    if (!hasNumber) return 'Add at least one number';
    return '';
  }

  bool get newPasswordsMatch =>
      confirmNewPassword.value.isNotEmpty &&
      confirmNewPassword.value == newPassword.value;

  void toggleNewPasswordVisibility() =>
      obscureNewPassword.value = !obscureNewPassword.value;
  void toggleConfirmNewPasswordVisibility() =>
      obscureConfirmNewPassword.value = !obscureConfirmNewPassword.value;

  /// Starts (or restarts) the 60s resend cooldown.
  void startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = kResendCooldown;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        t.cancel();
      } else {
        resendSeconds.value = resendSeconds.value - 1;
      }
    });
  }

  final HiveStore _store = HiveStore();

  @override
  void onInit() {
    super.onInit();
    loadRememberedCredentials();
    newPasswordController.addListener(() {
      newPassword.value = newPasswordController.text;
    });
    confirmNewPasswordController.addListener(() {
      confirmNewPassword.value = confirmNewPasswordController.text;
    });
  }

  /// If the user previously logged in with "Remember me" on, restore the saved
  /// email/password into the fields and pre-check the toggle. Safe to call
  /// more than once (e.g. each time the Login screen is shown) — it no-ops
  /// when nothing is remembered and never clobbers text the user is typing.
  void loadRememberedCredentials() {
    final bool remembered = _store.getBool(Keys.REMEMBERME) == true;
    if (!remembered) {
      rememberMe.value = false;
      return;
    }

    rememberMe.value = true;
    final savedEmail = _store.getString(Keys.SAVEDEMAIL) ?? '';
    final savedPassword = _store.getString(Keys.SAVEDPASSWORD) ?? '';
    if (emailController.text.isEmpty) emailController.text = savedEmail;
    if (passwordController.text.isEmpty) passwordController.text = savedPassword;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Only flips the preference. Nothing is persisted here — credentials are
  /// saved exclusively after a successful login (see [_onLoginSuccess]).
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> onLoginTap() async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate before hitting the network / persisting anything.
    if (!_isValidEmail(email)) {
      Get.snackbar(
        'Invalid email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password.isEmpty) {
      Get.snackbar(
        'Password required',
        'Please enter your password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await LoginService.instance.login(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _onLoginSuccess(email, password, result.response!);
      } else {
        Get.snackbar(
          'Login failed',
          result.error ?? 'Incorrect email or password.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Runs only after a successful login. Persists the session tokens and, when
  /// enabled, the remember-me credentials — so a wrong/incomplete email or
  /// password can never be saved.
  void _onLoginSuccess(String email, String password, LoginResponse res) {
    final tokens = res.data?.tokens;
    final user = res.data?.user;

    if (tokens != null) {
      _store.setString(Keys.AUTHTOKEN, tokens.accessToken);
      _store.setString(Keys.ACCESSTOKEN, tokens.accessToken);
      _store.setString(Keys.REFRESHTOKEN, tokens.refreshToken);
    }
    if (user != null) {
      _store.setString(Keys.USERID, user.id);
    }
    _store.setBool(Keys.LOGGEDIN, true);
    _store.setString(Keys.SAVEDAVATAR, user?.avatar_url ?? "");
    _store.setString(Keys.SAVEDPROFILENAME, user?.displayName ?? "");
    // Session identity — a real login (not register) is what establishes a
    // logged-in session, keyed off these fields at startup.
    _store.setString(
      Keys.SESSIONEMAIL,
      (user?.email.isNotEmpty == true) ? user!.email : email,
    );
    _store.setString(Keys.SESSIONDISPLAYNAME, user?.displayName ?? '');

    if (rememberMe.value) {
      _store.setBool(Keys.REMEMBERME, true);
      _store.setString(Keys.SAVEDEMAIL, email);
      _store.setString(Keys.SAVEDPASSWORD, password);
    } else {
      _store.remove(Keys.REMEMBERME);
      _store.remove(Keys.SAVEDEMAIL);
      _store.remove(Keys.SAVEDPASSWORD);
      // LoginController is permanent, so the typed values would otherwise
      // still be in the fields after logout. Clear them when not remembered.
      emailController.clear();
      passwordController.clear();
      obscurePassword.value = true;
    }

    debugPrint('Login succeeded -> ${user?.displayName}. Navigating home.');
    Get.offAllNamed(Routes.HOME);
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

  /// Validates the email and calls the forgot-password (send-OTP) API. On a
  /// successful response, clears any old OTP, starts the resend cooldown, and
  /// navigates to the OTP screen.
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
      final res = await LoginService.instance.sendOtp(email: email);
      if (res.success) {
        _clearOtp();
        startResendTimer();
        Get.snackbar(
          'Verification code sent',
          res.message.isNotEmpty
              ? res.message
              : "We've sent a 4-digit code to $email.",
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.toNamed(Routes.OTP, arguments: email);
      } else {
        Get.snackbar(
          'Could not send code',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSendingReset.value = false;
    }
  }

  // --- OTP handlers --------------------------------------------------------
  /// Email the OTP was sent to (passed as a route argument to the OTP screen).
  String get otpEmail => (Get.arguments is String)
      ? Get.arguments as String
      : forgotEmailController.text.trim();

  /// Bound to OTPTextField.onChanged — mirrors the entered pin into [otpCode].
  void onOtpChanged(String value) => otpCode.value = value;

  bool get isOtpComplete => otpCode.value.length == kOtpLength;

  Future<void> onVerifyOtp() async {
    if (isVerifyingOtp.value) return;
    if (!isOtpComplete) {
      Get.snackbar(
        'Incomplete code',
        'Please enter all $kOtpLength digits.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isVerifyingOtp.value = true;
    try {
      final res = await LoginService.instance.verifyEmail(
        email: otpEmail,
        otp: otpCode.value,
      );
      if (res.success) {
        resetToken.value = res.data?.resetToken ?? '';
        _clearNewPasswordFields();
        // Replace the OTP screen so "Back" from Reset returns to Forgot
        // Password, not the OTP screen.
        Get.offNamed(Routes.RESET_PASSWORD);
      } else {
        Get.snackbar(
          'Verification failed',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  // --- Reset password handlers --------------------------------------------
  Future<void> onResetPassword() async {
    if (isResettingPassword.value) return;

    if (!isNewPasswordValid) {
      Get.snackbar(
        'Weak password',
        passwordError.isNotEmpty
            ? passwordError
            : 'Please meet all password requirements.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!newPasswordsMatch) {
      Get.snackbar(
        'Passwords do not match',
        'Please make sure both passwords are identical.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isResettingPassword.value = true;
    try {
      final res = await LoginService.instance.resetPassword(
        resetToken: resetToken.value,
        newPassword: newPassword.value,
        confirmNewPassword: confirmNewPassword.value,
      );
      if (res.success) {
        Get.snackbar(
          'Password updated',
          res.message.isNotEmpty
              ? res.message
              : 'Your password has been reset. Please log in.',
          snackPosition: SnackPosition.BOTTOM,
        );
        _clearNewPasswordFields();
        resetToken.value = '';
        // Back to login, clearing the reset flow from the stack.
        Get.offAllNamed(Routes.LOGIN);
      } else {
        Get.snackbar(
          'Could not reset password',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isResettingPassword.value = false;
    }
  }

  /// Back from Reset Password goes to Forgot Password (not the OTP screen).
  void onBackFromReset() {
    _clearNewPasswordFields();
    Get.offNamed(Routes.FORGOT_PASSWORD);
  }

  void _clearNewPasswordFields() {
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    newPassword.value = '';
    confirmNewPassword.value = '';
  }

  Future<void> onResendOtp() async {
    if (isResendingOtp.value || !canResendOtp) return;
    isResendingOtp.value = true;
    try {
      final res = await LoginService.instance.sendOtp(email: otpEmail);
      if (res.success) {
        _clearOtp();
        startResendTimer();
        Get.snackbar(
          'Code resent',
          res.message.isNotEmpty
              ? res.message
              : "A new 4-digit code has been sent to $otpEmail.",
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
      isResendingOtp.value = false;
    }
  }

  void _clearOtp() {
    otpCode.value = '';
    // The OtpFieldController throws if the field isn't mounted yet, so guard.
    try {
      otpFieldController.clear();
    } catch (_) {}
  }

  void onBackToLogin() {
    Get.offAllNamed(Routes.LOGIN);
  }

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return regex.hasMatch(email);
  }

  void onCreateAccount() {
    // Flow: Policies Agreement -> Register -> Payment -> Profile Setup.
    Get.toNamed(Routes.POLICIES_AGREEMENT);
  }

  @override
  void onClose() {
    // NOTE: the text controllers are intentionally NOT disposed here. This
    // single LoginController is shared across the login/forgot/otp/reset
    // screens, and Get.offAll* tears the controller down mid-transition while
    // some TextFields may still be mounted — disposing the controllers then
    // triggers "TextEditingController used after being disposed". Leaving them
    // undisposed is safe (a few fields, freed on app exit) and avoids the crash.
    _resendTimer?.cancel();
    super.onClose();
  }
}
