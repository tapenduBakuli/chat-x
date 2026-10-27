import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../../login/model/login_response_model.dart';
import '../../login/services/login_services.dart';

/// Network layer for the register (sign-up) module. Mirrors [LoginService]:
/// wraps [BaseClient] so the controller stays free of HTTP/JSON details, and
/// reuses [LoginResult] / [LoginResponse] because the register response shape
/// is identical to login.
class RegisterService {
  RegisterService._();

  static final RegisterService instance = RegisterService._();

  /// POST /auth/register. [isAuth] is true so no bearer token is attached
  /// (sign-up is unauthenticated).
  Future<LoginResult> register({
    required String displayName,
    required String email,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
    required String country,
    required String promoCode,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.register,
        {
          "display_name": displayName,
          "email": email,
          "date_of_birth": dateOfBirth,
          "password": password,
          "confirm_password": confirmPassword,
          "country": country,
          "promo_code": promoCode,
        },
        isAuth: true,
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body is Map<String, dynamic>) {
          return LoginResult.success(LoginResponse.fromJson(body));
        }
        return const LoginResult.failure('Unexpected response from server.');
      }

      // Non-2xx: surface the server message when present.
      return LoginResult.failure(
        _extractMessage(body, 'Registration failed (${response.statusCode}).'),
      );
    } on AppException catch (e) {
      debugPrint('RegisterService.register AppException: ${e.message}');
      return LoginResult.failure(_messageForAppException(e));
    } catch (e) {
      debugPrint('RegisterService.register error: $e');
      return const LoginResult.failure(
        'Something went wrong. Please try again.',
      );
    }
  }

  /// Maps a BaseClient [AppException] to a user-facing message.
  String _messageForAppException(AppException e) {
    if (e.message == AppStrings.noInternetConnection) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Could not reach the server. Please try again.';
  }

  /// Pulls a human-readable message from a decoded error body, handling both
  /// the top-level `{ "message": ... }` shape and the nested error shape
  /// `{ "error": { "message": ... } }` (and a plain string `error`). Falls
  /// back to [fallback] when nothing usable is found.
  String _extractMessage(dynamic body, String fallback) {
    if (body is Map) {
      final topLevel = body['message'];
      if (topLevel != null && topLevel.toString().trim().isNotEmpty) {
        return topLevel.toString();
      }
      final err = body['error'];
      if (err is Map && err['message'] != null &&
          err['message'].toString().trim().isNotEmpty) {
        return err['message'].toString();
      }
      if (err is String && err.trim().isNotEmpty) {
        return err;
      }
    }
    return fallback;
  }
}
