class Urls {
  static const String baseUrl = "https://chatx-4le7.onrender.com";
  static const String apiv1 = "/api/v1/";

  /// Fully-qualified API root, e.g. https://chatx-4le7.onrender.com/api/v1/
  static const String apiBase = "$baseUrl$apiv1";

  // --- Auth ----------------------------------------------------------------
  static const String login = "${apiBase}auth/login";
  static const String register = "${apiBase}auth/register";
  static const String sendOtp = "${apiBase}auth/forgot-password";
  static const String verifyEmail = "${apiBase}auth/verify-email";
  static const String resetPassword = "${apiBase}auth/reset-password";

  // --- Users ---------------------------------------------------------------
  static const String savePaymentMethod = "${apiBase}users/me/payment-method";
}
