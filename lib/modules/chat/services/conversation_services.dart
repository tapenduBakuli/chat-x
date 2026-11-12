import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/chat_message.dart';
import '../model/conversation_model.dart';

/// Network layer for conversations. Mirrors FriendService: wraps [BaseClient]
/// so the controller stays free of HTTP/JSON details. Never throws.
class ConversationService {
  ConversationService._();

  static final ConversationService instance = ConversationService._();

  /// POST /conversations body {"other_user_id": userId} — [otherUserId] is
  /// the peer's USER id. Idempotent: creates or returns the existing
  /// conversation. Success is decided by status code (200/201) and a
  /// parsable `data` map.
  Future<({bool success, String message, Conversation? conversation})>
      openConversation(String otherUserId) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.conversations,
        <String, dynamic>{'other_user_id': otherUserId},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 || code == 201) {
        final data = body is Map ? body['data'] : null;
        if (data is Map) {
          final conversation =
              Conversation.fromJson(Map<String, dynamic>.from(data));
          if (conversation.id.isNotEmpty) {
            final serverMsg = body['message']?.toString().trim() ?? '';
            return (
              success: true,
              message: serverMsg.isNotEmpty ? serverMsg : 'Conversation ready',
              conversation: conversation,
            );
          }
        }
        return (
          success: false,
          message: 'Could not open the conversation. Please try again.',
          conversation: null,
        );
      }
      return (
        success: false,
        message: _extractMessage(
          body,
          'Could not open the conversation ($code).',
        ),
        conversation: null,
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e), conversation: null);
    } catch (e) {
      debugPrint('ConversationService.openConversation error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        conversation: null,
      );
    }
  }

  /// GET /conversations?limit=&offset= — my conversations, newest first.
  /// Never throws; failures come back with `success: false`.
  Future<ConversationListResponse> fetchConversations({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.conversationsPage(limit: limit, offset: offset),
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return ConversationListResponse.fromJson(body);
      }
      return ConversationListResponse(
        success: false,
        message: _extractMessage(body, 'Could not load conversations ($code).'),
      );
    } on AppException catch (e) {
      return ConversationListResponse(
          success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('ConversationService.fetchConversations error: $e');
      return const ConversationListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// GET /conversations/{id}/messages?limit=&offset= — NEWEST first.
  /// [isMine] decides left/right per raw item. Never throws; failures come
  /// back with `success: false`.
  Future<MessageListResponse> fetchMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
    required bool Function(Map<String, dynamic> json) isMine,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.get(
        Urls.conversationMessages(conversationId,
            limit: limit, offset: offset),
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map<String, dynamic>) {
        return MessageListResponse.fromJson(body, isMine: isMine);
      }
      return MessageListResponse(
        success: false,
        message: _extractMessage(body, 'Could not load messages ($code).'),
      );
    } on AppException catch (e) {
      return MessageListResponse(success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('ConversationService.fetchMessages error: $e');
      return const MessageListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// POST /conversations/{id}/messages body {"content": content}. Success is
  /// decided by status code (200/201) and a `data` map with a non-empty id,
  /// parsed with [ChatMessage.fromApiJson]. Never throws.
  Future<({bool success, String message, ChatMessage? sent})> sendMessage(
    String conversationId,
    String content, {
    required bool Function(Map<String, dynamic> json) isMine,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.sendConversationMessage(conversationId),
        <String, dynamic>{'content': content},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 || code == 201) {
        final data = body is Map ? body['data'] : null;
        if (data is Map) {
          final sent = ChatMessage.fromApiJson(
            Map<String, dynamic>.from(data),
            isMine: isMine,
          );
          if (sent != null) {
            final serverMsg = body['message']?.toString().trim() ?? '';
            return (
              success: true,
              message: serverMsg.isNotEmpty ? serverMsg : 'Message sent',
              sent: sent,
            );
          }
        }
        return (
          success: false,
          message: 'Could not send the message. Please try again.',
          sent: null,
        );
      }
      return (
        success: false,
        message: _extractMessage(body, 'Could not send the message ($code).'),
        sent: null,
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e), sent: null);
    } catch (e) {
      debugPrint('ConversationService.sendMessage error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        sent: null,
      );
    }
  }

  /// DELETE /messages/{messageId}?for_everyone=false.
  /// Checks status code (200 / 204) for API success. Never throws.
  Future<({bool success, String message})> deleteMessage(
    String messageId, {
    bool forEveryone = false,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.deleteMessage(messageId, forEveryone: forEveryone),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 || code == 204) {
        final serverMsg =
            body is Map ? (body['message']?.toString().trim() ?? '') : '';
        return (
          success: true,
          message: serverMsg.isNotEmpty ? serverMsg : 'Message deleted',
        );
      }
      return (
        success: false,
        message: _extractMessage(body, 'Could not delete the message ($code).'),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('ConversationService.deleteMessage error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
      );
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

  /// POST conversations/{conversationId}/clear — clears all messages for me
  /// and keeps the conversation in the list. Success is decided by status
  /// code only (200/202/204; the body may be empty). Never throws; failures
  /// come back with `success: false`.
  Future<({bool success, String message})> clearConversation(
    String conversationId,
  ) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.clearConversation(conversationId),
        <String, dynamic>{},
      );
      // [OLD – was DELETE conversations/{id}, which also hid the chat]
      // final http.Response response = await BaseClient.instance.delete(
      //   Urls.clearConversation(conversationId),
      //   <String, dynamic>{},
      // );
      final int code = response.statusCode;
      final dynamic body = _decode(response);
      if (code == 200 || code == 202 || code == 204) {
        return (success: true, message: _extractMessage(body, ''));
      }
      debugPrint('ConversationService.clearConversation -> $code');
      return (
        success: false,
        message: _extractMessage(body, 'Could not clear the chat ($code).'),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('ConversationService.clearConversation error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
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
