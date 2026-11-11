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

  /// POST, unauthenticated; body {refresh_token}. Returns a new access token
  /// AND a new (rotated) refresh token.
  static const String authRefresh = "${apiBase}auth/refresh";
  // NOTE: endpoint path assumed — update if the backend uses a different one.
  static const String changePassword = "${apiBase}auth/change-password";

  // --- Users ---------------------------------------------------------------
  static const String savePaymentMethod = "${apiBase}users/me/payment-method";
  static const String uploadAvatar = "${apiBase}users/me/avatar";

  /// GET — lists my gallery photos; POST (multipart, field `file`) — uploads
  /// one gallery photo.
  static const String myPhotos = "${apiBase}users/me/photos";

  /// DELETE — removes one gallery photo: users/me/photos/{photo_id}
  static String myPhotoById(String photoId) => "$myPhotos/$photoId";

  /// PUT — reorders my gallery; body {"photo_ids": [...]} in new order.
  static const String reorderMyPhotos = "$myPhotos/reorder";
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
  /// PATCH — partial update of the current user (e.g. is_invisible).
  static const String patchMyProfile = "${apiBase}users/me";
  /// GET — fetches the current user's account + profile.
  static const String getMyProfile = "${apiBase}users/me";
  static const String updatePassword = "${apiBase}users/me/password";
  /// GET — lists browsable members (limit/offset + optional gender/age).
  static const String users = "${apiBase}users";

  /// GET — fetches a single user's full profile by ID: users/{user_id}
  static String getUserById(String userId) =>
      "$users/${Uri.encodeComponent(userId)}";

  /// GET — fetches user availability status by ID: users/{user_id}/availability
  static String getUserAvailability(String userId) =>
      "$users/${Uri.encodeComponent(userId)}/availability";

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

  /// GET — paginated list of saved profiles; query: limit, offset.
  static const String friends = "${apiBase}friends";

  /// POST — saves a member: friends/{user_id}
  static String saveProfile(String userId) => "$friends/$userId";

  /// DELETE — removes a saved profile: friends/{user_id}
  /// (the FRIEND'S USER id `items[].user.id`, not the friendship id).
  static String removeFriend(String userId) => "$friends/$userId";

  // --- Chat ----------------------------------------------------------------
  /// POST — creates or returns the 1:1 conversation with a user; body
  /// `{"other_user_id": "USER_ID"}`.
  static const String conversations = "${apiBase}conversations";

  /// GET — paginated conversation list. Builds the exact URL
  /// conversations?limit=..&offset=.. (BaseClient.get's `query:` would add a
  /// trailing `&`, so it is not used).
  static String conversationsPage({int limit = 20, int offset = 0}) =>
      "$conversations?limit=$limit&offset=$offset";

  /// GET — paginated messages of a conversation, NEWEST first:
  /// conversations/{conversationId}/messages?limit=..&offset=..
  static String conversationMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) =>
      "$conversations/${Uri.encodeComponent(conversationId)}/messages"
      "?limit=$limit&offset=$offset";

  /// POST — sends a message; body `{"content": "..."}`. Same path as
  /// [conversationMessages] but WITHOUT the query string:
  /// conversations/{conversationId}/messages
  static String sendConversationMessage(String conversationId) =>
      "$conversations/${Uri.encodeComponent(conversationId)}/messages";

  /// WebSocket URL for realtime chat connection.
  static String wsChatUrl(String token) =>
      "wss://chatx-4le7.onrender.com/api/v1/ws/chat?token=${Uri.encodeComponent(token)}";

  /// DELETE — deletes a message: messages/{messageId}?for_everyone=false
  static String deleteMessage(String messageId, {bool forEveryone = false}) =>
      "${apiBase}messages/${Uri.encodeComponent(messageId)}?for_everyone=$forEveryone";
}
