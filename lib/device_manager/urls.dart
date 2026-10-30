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
  // --- Notifications -------------------------------------------------------
  /// GET — paginated list; query: unread_only, limit, offset.
  static const String notifications = "${apiBase}notifications";

  /// POST — marks every notification as read.
  static const String notificationsReadAll = "${apiBase}notifications/read-all";

  /// POST — marks one notification as read: notifications/{id}/read
  static String notificationRead(String id) => "${apiBase}notifications/$id/read";

  /// DELETE — deletes one notification: notifications/{id}
  static String notificationById(String id) => "${apiBase}notifications/$id";

  /// DELETE — deletes the current user's account.
  static const String deleteAccount = "${apiBase}users/me";
  /// PUT — updates the current user's profile (post-payment onboarding).
  static const String updateProfile = "${apiBase}users/me";
  /// GET — fetches the current user's account + profile.
  static const String getMyProfile = "${apiBase}users/me";
  static const String updatePassword = "${apiBase}users/me/password";
  /// GET — lists browsable members (limit/offset + optional gender/age).
  static const String users = "${apiBase}users";

  // --- Friends -------------------------------------------------------------
  /// Base path for friend requests.
  static const String friendRequests = "${apiBase}friends/requests/";

  /// POST — sends a friend request to a member: friends/requests/{user_id}
  static String sendFriendRequest(String userId) => "$friendRequests$userId";
}
