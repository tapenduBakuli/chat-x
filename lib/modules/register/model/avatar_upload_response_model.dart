/// Response for POST /users/me/avatar.
///
/// {
///   "success": bool,
///   "message": string,
///   "data": { "avatar_url": string, "user": { ... } }
/// }
///
/// Only the fields the app currently needs are modeled (success, message,
/// avatar_url). The nested user object is ignored for now.
class AvatarUploadResponseModel {
  final bool success;
  final String message;
  final String avatarUrl;

  const AvatarUploadResponseModel({
    required this.success,
    required this.message,
    required this.avatarUrl,
  });

  factory AvatarUploadResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AvatarUploadResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      avatarUrl: (data is Map && data['avatar_url'] != null)
          ? data['avatar_url'].toString()
          : '',
    );
  }
}
