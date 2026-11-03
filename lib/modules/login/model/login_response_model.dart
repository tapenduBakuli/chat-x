
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

  /// Top-level `data.avatar_url` ('' when null/missing).
  final String avatarUrl;

  const LoginData({this.user, this.tokens, this.avatarUrl = ''});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: json['user'] is Map<String, dynamic>
          ? LoginUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      tokens: json['tokens'] is Map<String, dynamic>
          ? AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>)
          : null,
      avatarUrl: (json['avatar_url'] ?? '').toString(),
    );
  }
}

class LoginUser {
  final String id;
  final String email;
  final String displayName;
  final String avatar_url;
  final String? dateOfBirth;
  final String? country;
  final String? promoCode;
  final String role;
  final bool isInvisible;
  final String? trialEndsAt;
  final String? createdAt;

  /// `has_payment_method` from `data.user`. null when missing/not a bool, so
  /// only an explicit `false` means "unpaid" (see requiresPaymentGate).
  final bool? hasPaymentMethod;

  /// `data.user.profile.avatar_url` ('' when null/missing).
  final String profileAvatarUrl;

  const LoginUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatar_url,
    this.dateOfBirth,
    this.country,
    this.promoCode,
    required this.role,
    required this.isInvisible,
    this.trialEndsAt,
    this.createdAt,
    this.hasPaymentMethod,
    this.profileAvatarUrl = '',
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final hasPayment = json['has_payment_method'];
    return LoginUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      avatar_url: (json['avatar_url'] ?? '').toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      country: json['country']?.toString(),
      promoCode: json['promo_code']?.toString(),
      role: (json['role'] ?? '').toString(),
      isInvisible: json['is_invisible'] == true,
      trialEndsAt: json['trial_ends_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      hasPaymentMethod: hasPayment is bool ? hasPayment : null,
      profileAvatarUrl:
          profile is Map ? (profile['avatar_url'] ?? '').toString() : '',
    );
  }
}

/// Response of POST /auth/refresh:
/// `{ "success", "message", "data": { access_token, refresh_token,
/// token_type, expires_in } }`. The refresh token rotates on every call.
class RefreshTokenResponse {
  final bool success;
  final String message;
  final AuthTokens? tokens;

  const RefreshTokenResponse({
    required this.success,
    required this.message,
    this.tokens,
  });

  /// True when the call succeeded and returned a usable access token.
  bool get isValid =>
      success && tokens != null && tokens!.accessToken.isNotEmpty;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return RefreshTokenResponse(
      // Only an explicit `success: false` fails; a missing key relies on the
      // access token being present.
      success: json['success'] != false,
      message: (json['message'] ?? '').toString(),
      tokens: data is Map
          ? AuthTokens.fromJson(Map<String, dynamic>.from(data))
          : null,
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
