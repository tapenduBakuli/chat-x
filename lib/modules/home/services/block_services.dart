import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/friend.dart';

/// Network layer for blocking / unblocking members. Mirrors FriendService:
/// wraps [BaseClient] so the controller stays free of HTTP/JSON details.
class BlockService {
  BlockService._();

  static final BlockService instance = BlockService._();

  /// POST /users/{userId}/block (authenticated, no request body). Success is
  /// decided by status code only (200/201/204) — the body may be empty. On
  /// success `message` is the server message, or '' when it sent none (the
  /// caller supplies its own fallback).
  Future<({bool success, String message})> blockUser(String userId) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.blockUser(userId),
        <String, dynamic>{},
      );
      return _result(response, 'Could not block user');
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('BlockService.blockUser error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// DELETE /users/{userId}/block. Same success/message rules as [blockUser].
  Future<({bool success, String message})> unblockUser(String userId) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.blockUser(userId),
        <String, dynamic>{},
      );
      return _result(response, 'Could not unblock user');
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('BlockService.unblockUser error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// GET /users/blocked?limit=&offset= — users I blocked. Never throws;
  /// failures come back with `success: false`.
  Future<BlockedUserListResponse> fetchBlockedUsers({
    int limit = 40,
    int offset = 0,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.blockedUsers,
        query: <String, dynamic>{'limit': limit, 'offset': offset},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return BlockedUserListResponse.fromJson(body);
      }
      return BlockedUserListResponse(
        success: false,
        message: _extractMessage(body, 'Could not load blocked users ($code).'),
      );
    } on AppException catch (e) {
      return BlockedUserListResponse(
          success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('BlockService.fetchBlockedUsers error: $e');
      return const BlockedUserListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  ({bool success, String message}) _result(
      http.Response response, String failurePrefix) {
    final code = response.statusCode;
    final body = _decode(response);
    if (code == 200 || code == 201 || code == 204) {
      final serverMsg = body is Map &&
              body['message'] != null &&
              body['message'].toString().trim().isNotEmpty
          ? body['message'].toString()
          : '';
      return (success: true, message: serverMsg);
    }
    return (
      success: false,
      message: _extractMessage(body, '$failurePrefix ($code).'),
    );
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
