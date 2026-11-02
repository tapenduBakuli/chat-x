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

  /// POST blocks / DELETE unblocks a member: users/{user_id}/block
  /// (the member's USER id).
  static String blockUser(String userId) => "$users/$userId/block";

  /// GET — paginated list of users I blocked; query: limit, offset.
  static const String blockedUsers = "$users/blocked";

  // --- Friends -------------------------------------------------------------
  /// Base path for friend requests.
  static const String friendRequests = "${apiBase}friends/requests/";

  /// POST — sends a friend request to a member: friends/requests/{user_id}
  static String sendFriendRequest(String userId) => "$friendRequests$userId";

  /// GET — paginated list of requests I sent; query: limit, offset.
  static const String sentFriendRequests = "${friendRequests}sent";

  /// DELETE — cancels a sent request: friends/requests/sent/{request_id}
  /// (the REQUEST id, not the addressee's user id).
  static String cancelSentRequest(String requestId) =>
      "$sentFriendRequests/$requestId";

  /// GET — paginated list of requests I received; query: limit, offset.
  /// No trailing slash (unlike [friendRequests]) so BaseClient.get builds
  /// friends/requests?limit=..&offset=..
  static const String incomingFriendRequests = "${apiBase}friends/requests";

  /// POST — accepts a received request: friends/requests/{request_id}/accept
  /// (the REQUEST id `items[].id`, not the requester's user id).
  static String acceptFriendRequest(String requestId) =>
      "$friendRequests$requestId/accept";

  /// POST — rejects a received request: friends/requests/{request_id}/reject
  /// (the REQUEST id `items[].id`, not the requester's user id).
  static String rejectFriendRequest(String requestId) =>
      "$friendRequests$requestId/reject";

  /// DELETE — deletes a received request without accepting or rejecting it:
  /// friends/requests/{request_id} (the REQUEST id `items[].id`, not the
  /// requester's user id).
  static String deleteFriendRequest(String requestId) =>
      "$friendRequests$requestId";

  /// GET — paginated list of my friends; query: limit, offset.
  static const String friends = "${apiBase}friends";

  /// DELETE — removes a friend: friends/{user_id}
  /// (the FRIEND'S USER id `items[].user.id`, not the friendship id).
  static String removeFriend(String userId) => "$friends/$userId";
}
