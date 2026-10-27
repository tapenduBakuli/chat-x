
class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  const LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginData {
  final LoginUser? user;
  final AuthTokens? tokens;

  const LoginData({this.user, this.tokens});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: json['user'] is Map<String, dynamic>
          ? LoginUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      tokens: json['tokens'] is Map<String, dynamic>
          ? AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginUser {
  final String id;
  final String email;
  final String displayName;
  final String? dateOfBirth;
  final String? country;
  final String? promoCode;
  final String role;
  final bool isInvisible;
  final String? trialEndsAt;
  final String? createdAt;

  const LoginUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.dateOfBirth,
    this.country,
    this.promoCode,
    required this.role,
    required this.isInvisible,
    this.trialEndsAt,
    this.createdAt,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      country: json['country']?.toString(),
      promoCode: json['promo_code']?.toString(),
      role: (json['role'] ?? '').toString(),
      isInvisible: json['is_invisible'] == true,
      trialEndsAt: json['trial_ends_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      tokenType: (json['token_type'] ?? '').toString(),
      expiresIn: json['expires_in'] is int
          ? json['expires_in'] as int
          : int.tryParse('${json['expires_in']}') ?? 0,
    );
  }
}
