import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/member.dart';

/// Network layer for the Browse Members list. Mirrors NotificationService:
/// wraps [BaseClient] so the controller stays free of HTTP/JSON details.
class MemberService {
  MemberService._();

  static final MemberService instance = MemberService._();

  /// GET /users (authenticated). `limit`/`offset` are always sent; `gender`,
  /// `min_age` and `max_age` are added ONLY when non-null, because
  /// [BaseClient.get] serialises every map entry (so a default call carries no
  /// gender/age params at all).
  Future<MemberListResponse> fetchMembers({
    required int limit,
    required int offset,
    String? gender,
    int? minAge,
    int? maxAge,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        // Null-aware entries: omitted entirely when the value is null.
        'gender': ?gender,
        'min_age': ?minAge,
        'max_age': ?maxAge,
      };

      final http.Response response =
          await BaseClient.instance.get(Urls.users, query: query);

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        return MemberListResponse.fromJson(body);
      }

      return MemberListResponse(
        success: false,
        message: _extractMessage(
          body,
          'Could not load members (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return MemberListResponse(
        success: false,
        message: e.message == AppStrings.noInternetConnection
            ? 'No internet connection. Please check your network and try again.'
            : 'Could not reach the server. Please try again.',
      );
    } catch (e) {
      debugPrint('MemberService.fetchMembers error: $e');
      return const MemberListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Top-level `message`, nested `error.message`, or string `error`.
  String _extractMessage(dynamic body, String fallback) {
    if (body is Map) {
      final top = body['message'];
      if (top != null && top.toString().trim().isNotEmpty) {
        return top.toString();
      }
      final err = body['error'];
      if (err is Map &&
          err['message'] != null &&
          err['message'].toString().trim().isNotEmpty) {
        return err['message'].toString();
      }
      if (err is String && err.trim().isNotEmpty) return err;
    }
    return fallback;
  }
}
