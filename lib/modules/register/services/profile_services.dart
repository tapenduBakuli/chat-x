import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/update_profile_response_model.dart';

/// Network layer for updating the current user's profile. Mirrors
/// [PaymentService]: wraps [BaseClient] so the controller stays free of
/// HTTP/JSON details.
class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  /// PUT /users/me — updates the current user's profile.
  ///
  /// AUTHENTICATED call: [isAuth] is left at its default (false) so
  /// [BaseClient] attaches the bearer token (ACCESSTOKEN → REGISTRATIONTOKEN
  /// → AUTHTOKEN fallback; right after register the registration token).
  Future<UpdateProfileResponseModel> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    try {
      final http.Response response = await BaseClient.instance.put(
        Urls.updateProfile,
        payload,
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        return UpdateProfileResponseModel.fromJson(body);
      }

      return UpdateProfileResponseModel(
        success: false,
        message: _extractMessage(
          body,
          'Could not update profile (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return UpdateProfileResponseModel(
        success: false,
        message: _messageForAppException(e),
      );
    } catch (e) {
      debugPrint('ProfileService.updateProfile error: $e');
      return const UpdateProfileResponseModel(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// GET /users/me — fetches the current user's account and profile.
  ///
  /// AUTHENTICATED call: [BaseClient.get] always attaches the bearer token
  /// (for a logged-in user that's ACCESSTOKEN).
  Future<UpdateProfileResponseModel> getMyProfile() async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.getMyProfile);

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        return UpdateProfileResponseModel.fromJson(body);
      }

      return UpdateProfileResponseModel(
        success: false,
        message: _extractMessage(
          body,
          'Could not load profile (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return UpdateProfileResponseModel(
        success: false,
        message: _messageForAppException(e),
      );
    } catch (e) {
      debugPrint('ProfileService.getMyProfile error: $e');
      return const UpdateProfileResponseModel(
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
