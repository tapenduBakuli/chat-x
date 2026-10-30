import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/notification_model.dart';

/// Network layer for notifications. Mirrors the other services: wraps
/// [BaseClient] so the controller stays free of HTTP/JSON details.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// GET /notifications (authenticated). `unread_only` is always false — the
  /// list shows read and unread items; unread ones are highlighted in the UI.
  Future<NotificationListResponse> fetchNotifications({
    required int limit,
    required int offset,
    bool unreadOnly = false,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.notifications,
        query: {
          'unread_only': unreadOnly,
          'limit': limit,
          'offset': offset,
        },
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        return NotificationListResponse.fromJson(body);
      }

      return NotificationListResponse(
        success: false,
        message: _extractMessage(
          body,
          'Could not load notifications (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return NotificationListResponse(
        success: false,
        message: e.message == AppStrings.noInternetConnection
            ? 'No internet connection. Please check your network and try again.'
            : 'Could not reach the server. Please try again.',
      );
    } catch (e) {
      debugPrint('NotificationService.fetchNotifications error: $e');
      return const NotificationListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Exact unread count for the header badge: asks for unread only with
  /// limit=1 and reads `total`, so it's a tiny request. Returns null on
  /// failure (caller keeps the current badge rather than wiping it).
  Future<int?> fetchUnreadCount() async {
    final res = await fetchNotifications(limit: 1, offset: 0, unreadOnly: true);
    return res.success ? res.total : null;
  }

  /// POST /notifications/read-all. Success = 200/201/204.
  Future<({bool success, String message})> markAllAsRead() async {
    return _postAction(
      Urls.notificationsReadAll,
      okMessage: 'All notifications marked as read',
      failMessage: 'Could not mark notifications as read',
    );
  }

  /// POST /notifications/{id}/read. Success = 200/201/204.
  Future<({bool success, String message})> markAsRead(String id) async {
    return _postAction(
      Urls.notificationRead(id),
      okMessage: '',
      failMessage: 'Could not mark notification as read',
    );
  }

  /// DELETE /notifications/{id}. No body — success is confirmed by status
  /// code only (200 or 204).
  Future<({bool success, String message})> deleteNotification(
      String id) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.notificationById(id),
        <String, dynamic>{},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return (success: true, message: 'Notification deleted');
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not delete notification (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('NotificationService.deleteNotification error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// Shared POST for the two "mark read" actions (no request body).
  Future<({bool success, String message})> _postAction(
    String path, {
    required String okMessage,
    required String failMessage,
  }) async {
    try {
      final http.Response response =
          await BaseClient.instance.post(path, <String, dynamic>{});
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map && body['message'] != null
            ? body['message'].toString()
            : '';
        return (
          success: true,
          message: serverMsg.isNotEmpty ? serverMsg : okMessage,
        );
      }
      return (
        success: false,
        message: _extractMessage(_decode(response), '$failMessage ($code).'),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('NotificationService._postAction($path) error: $e');
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
