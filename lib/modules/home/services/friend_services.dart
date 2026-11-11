import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/friend.dart';

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

  /// POST /friends/{userId} — saves a member (Saved profiles flow).
  /// Success is decided by status code only (200/201/204) — the body may be
  /// empty.
  Future<({bool success, String message})> saveContact(String userId) async {
    if (userId.isEmpty) {
      return (success: false, message: 'Could not save contact.');
    }
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.saveProfile(userId),
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
          'Could not save contact ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.saveContact error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// GET /friends?limit=&offset= — my saved profiles. Never throws; failures
  /// come back with `success: false`.
  Future<SavedProfileListResponse> fetchSavedProfiles({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.friends,
        query: <String, dynamic>{'limit': limit, 'offset': offset},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return SavedProfileListResponse.fromJson(body);
      }
      return SavedProfileListResponse(
        success: false,
        message:
            _extractMessage(body, 'Could not load saved profiles ($code).'),
      );
    } on AppException catch (e) {
      return SavedProfileListResponse(
          success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.fetchSavedProfiles error: $e');
      return const SavedProfileListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// GET /friends/requests/sent?limit=&offset= — requests I sent that are
  /// still pending. Never throws; failures come back with `success: false`.
  Future<SentFriendRequestListResponse> fetchSentRequests({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.sentFriendRequests,
        query: <String, dynamic>{'limit': limit, 'offset': offset},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return SentFriendRequestListResponse.fromJson(body);
      }
      return SentFriendRequestListResponse(
        success: false,
        message: _extractMessage(body, 'Could not load sent requests ($code).'),
      );
    } on AppException catch (e) {
      return SentFriendRequestListResponse(
          success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.fetchSentRequests error: $e');
      return const SentFriendRequestListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// DELETE /friends/requests/sent/{requestId} — [requestId] is the request's
  /// own id (`items[].id`), not the addressee's user id. Success is decided by
  /// status code only (200/201/204) — the body may be empty.
  Future<({bool success, String message})> cancelSentRequest(
      String requestId) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.cancelSentRequest(requestId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map &&
                body['message'] != null &&
                body['message'].toString().trim().isNotEmpty
            ? body['message'].toString()
            : 'Request cancelled';
        return (success: true, message: serverMsg);
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not cancel request ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.cancelSentRequest error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// GET /friends/requests?limit=&offset= — requests I received that are
  /// still pending. Never throws; failures come back with `success: false`.
  Future<IncomingFriendRequestListResponse> fetchIncomingRequests({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.incomingFriendRequests,
        query: <String, dynamic>{'limit': limit, 'offset': offset},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return IncomingFriendRequestListResponse.fromJson(body);
      }
      return IncomingFriendRequestListResponse(
        success: false,
        message:
            _extractMessage(body, 'Could not load friend requests ($code).'),
      );
    } on AppException catch (e) {
      return IncomingFriendRequestListResponse(
          success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.fetchIncomingRequests error: $e');
      return const IncomingFriendRequestListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// POST /friends/requests/{requestId}/accept — [requestId] is the
  /// request's own id (`items[].id`), not the requester's user id. Success is
  /// decided by status code only (200/201/204) — the body may be empty.
  Future<({bool success, String message})> acceptFriendRequest(
      String requestId) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.acceptFriendRequest(requestId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map &&
                body['message'] != null &&
                body['message'].toString().trim().isNotEmpty
            ? body['message'].toString()
            : 'Request accepted';
        return (success: true, message: serverMsg);
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not accept request ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.acceptFriendRequest error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// POST /friends/requests/{requestId}/reject — [requestId] is the
  /// request's own id (`items[].id`), not the requester's user id. Success is
  /// decided by status code only (200/201/204) — the body may be empty.
  Future<({bool success, String message})> rejectFriendRequest(
      String requestId) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.rejectFriendRequest(requestId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map &&
                body['message'] != null &&
                body['message'].toString().trim().isNotEmpty
            ? body['message'].toString()
            : 'Request declined';
        return (success: true, message: serverMsg);
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not decline request ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.rejectFriendRequest error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// DELETE /friends/requests/{requestId} — deletes a received request
  /// without accepting or rejecting it. [requestId] is the request's own id
  /// (`items[].id`), not the requester's user id. Success is decided by
  /// status code only (200/201/204) — the body may be empty.
  Future<({bool success, String message})> deleteFriendRequest(
      String requestId) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.deleteFriendRequest(requestId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map &&
                body['message'] != null &&
                body['message'].toString().trim().isNotEmpty
            ? body['message'].toString()
            : 'Request deleted';
        return (success: true, message: serverMsg);
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not delete request ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.deleteFriendRequest error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// GET /friends?limit=&offset= — my accepted friends. Never throws;
  /// failures come back with `success: false`.
  Future<FriendshipListResponse> fetchFriends({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.friends,
        query: <String, dynamic>{'limit': limit, 'offset': offset},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return FriendshipListResponse.fromJson(body);
      }
      return FriendshipListResponse(
        success: false,
        message: _extractMessage(body, 'Could not load friends ($code).'),
      );
    } on AppException catch (e) {
      return FriendshipListResponse(
          success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.fetchFriends error: $e');
      return const FriendshipListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// DELETE /friends/{userId} — [userId] is the friend's USER id
  /// (`items[].user.id`), not the friendship id (`items[].id`). Success is
  /// decided by status code only (200/201/204) — the body may be empty.
  Future<({bool success, String message})> removeFriend(String userId) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.removeFriend(userId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 201 || code == 204) {
        final body = _decode(response);
        final serverMsg = body is Map &&
                body['message'] != null &&
                body['message'].toString().trim().isNotEmpty
            ? body['message'].toString()
            : 'Friend removed';
        return (success: true, message: serverMsg);
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not remove friend ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('FriendService.removeFriend error: $e');
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
