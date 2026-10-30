import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';

/// Network layer for friend actions. Mirrors NotificationService: wraps
/// [BaseClient] so the controller stays free of HTTP/JSON details.
class FriendService {
  FriendService._();

  static final FriendService instance = FriendService._();

  /// POST /friends/requests/{userId} (authenticated, no request body).
  /// Success is decided by status code only (200/201/204) — the body may be
  /// empty.
  Future<({bool success, String message})> sendFriendRequest(
      String userId) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.sendFriendRequest(userId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map && body['message'] != null
            ? body['message'].toString()
            : '';
        return (success: true, message: serverMsg);
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not send friend request ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.sendFriendRequest error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  dynamic _decode(http.Response r) {
    if (r.body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _offlineMessage(AppException e) =>
      e.message == AppStrings.noInternetConnection
          ? 'No internet connection. Please check your network and try again.'
          : 'Could not reach the server. Please try again.';

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
