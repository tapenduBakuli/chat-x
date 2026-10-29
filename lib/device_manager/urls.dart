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
  static const String logout = "${apiBase}auth/logout";
  // NOTE: endpoint path assumed — update if the backend uses a different one.
  static const String changePassword = "${apiBase}auth/change-password";

  // --- Users ---------------------------------------------------------------
  static const String savePaymentMethod = "${apiBase}users/me/payment-method";
  static const String uploadAvatar = "${apiBase}users/me/avatar";
  /// DELETE — deletes the current user's account.
  static const String deleteAccount = "${apiBase}users/me";
  /// PUT — updates the current user's profile (post-payment onboarding).
  static const String updateProfile = "${apiBase}users/me";
  /// GET — fetches the current user's account + profile.
  static const String getMyProfile = "${apiBase}users/me";
  static const String updatePassword = "${apiBase}users/me/password";
}
