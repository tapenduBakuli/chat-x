import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/login_response_model.dart';
import '../model/send_otp_response_model.dart';
import '../model/verify_email_response_model.dart';

/// Outcome of a login API call: either a parsed [LoginResponse] on success, or
/// a human-readable [error] message on failure.
class LoginResult {
  final LoginResponse? response;
  final String? error;

  const LoginResult.success(this.response) : error = null;
  const LoginResult.failure(this.error) : response = null;

  bool get isSuccess => response != null && response!.success;
}



/// Network layer for the login module. Wraps [BaseClient] so the controller
/// stays free of HTTP/JSON details.
class LoginService {
  LoginService._();

  static final LoginService instance = LoginService._();

  /// POST /auth/login. [isAuth] is true so no bearer token is attached.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.login,
        {"email": email, "password": password},
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
        _extractMessage(body, 'Login failed (${response.statusCode}).'),
      );
    } on AppException catch (e) {
      debugPrint('LoginService.login AppException: ${e.message}');
      // BaseClient throws this with the noInternetConnection message when the
      // pre-request connectivity check fails.
      if (e.message == AppStrings.noInternetConnection) {
        return const LoginResult.failure(
          'No internet connection. Please check your network and try again.',
        );
      }
      return const LoginResult.failure(
        'Could not reach the server. Please try again.',
      );
    } catch (e) {
      debugPrint('LoginService.login error: $e');
      return const LoginResult.failure(
        'Something went wrong. Please try again.',
      );
    }
  }

  /// POST /auth/forgot-password — sends a reset OTP to [email].
  /// Payload: { "email": ... }. Response parsed into [OtpResponseModel].
  Future<OtpResponseModel> sendOtp({required String email}) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.sendOtp,
        {"email": email},
        isAuth: true,
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        return OtpResponseModel.fromJson(body);
      }

      return OtpResponseModel(
        success: false,
        message: _extractMessage(
          body,
          'Could not send OTP (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return OtpResponseModel(success: false, message: _messageForAppException(e));
    } catch (e) {
      debugPrint('LoginService.sendOtp error: $e');
      return OtpResponseModel(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// POST /auth/verify-email — verifies the OTP for [email].
  /// Payload: { "email": ..., "otp": ... }. Parsed into
  /// [VerifyEmailResponseModel] (its data carries the reset_token).
  Future<VerifyEmailResponseModel> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.verifyEmail,
        {"email": email, "otp": otp},
        isAuth: true,
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        return VerifyEmailResponseModel.fromJson(body);
      }

      return VerifyEmailResponseModel(
        success: false,
        message: _extractMessage(
          body,
          'Could not verify the code (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return VerifyEmailResponseModel(
        success: false,
        message: _messageForAppException(e),
      );
    } catch (e) {
      debugPrint('LoginService.verifyEmail error: $e');
      return VerifyEmailResponseModel(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// POST /auth/reset-password — sets the new password using the reset token
  /// from verify-email. Payload:
  /// { "reset_token", "new_password", "confirm_new_password" }.
  /// Response shape matches [OtpResponseModel] ({ success, message, data }).
  Future<OtpResponseModel> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.resetPassword,
        {
          "reset_token": resetToken,
          "new_password": newPassword,
          "confirm_new_password": confirmNewPassword,
        },
        isAuth: true,
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        return OtpResponseModel.fromJson(body);
      }

      return OtpResponseModel(
        success: false,
        message: _extractMessage(
          body,
          'Could not reset password (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return OtpResponseModel(
        success: false,
        message: _messageForAppException(e),
      );
    } catch (e) {
      debugPrint('LoginService.resetPassword error: $e');
      return OtpResponseModel(
        success: false,
        message: 'Something went wrong. Please try again.',
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
