/// Response for POST /auth/verify-email.
///
/// {
///   "success": bool,
///   "message": string,
///   "data": { "reset_token": string }
/// }
class VerifyEmailResponseModel {
  final bool success;
  final String message;
  final VerifyEmailData? data;

  VerifyEmailResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerifyEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? VerifyEmailData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VerifyEmailData {
  final String resetToken;

  VerifyEmailData({required this.resetToken});

  factory VerifyEmailData.fromJson(Map<String, dynamic> json) {
    return VerifyEmailData(
      resetToken: (json['reset_token'] ?? '').toString(),
    );
  }
}
