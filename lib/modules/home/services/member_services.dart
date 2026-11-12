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
    String? region,
    int? radius,
    List<String>? interests,
    bool? onlyOnline,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        if (gender != null && gender.isNotEmpty && gender.toLowerCase() != 'all')
          'gender': gender.toLowerCase(),
        if (minAge != null) 'min_age': minAge,
        if (maxAge != null) 'max_age': maxAge,
        if (region != null && region.isNotEmpty && region != 'All Belgium')
          'region': region,
        if (radius != null) 'radius': radius,
        if (interests != null && interests.isNotEmpty) 'interests': interests,
        if (onlyOnline != null && onlyOnline) 'only_online': onlyOnline,
      };

      debugPrint('MemberService.fetchMembers: Executing filter fetch with params -> $query');

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

  /// GET /users/{user_id} (authenticated) — fetches a single member's full profile.
  Future<({bool success, String message, Member? member})> fetchMemberById(
      String userId) async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.getUserById(userId));

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final member = Member.fromJson(data);
          return (
            success: true,
            message: _extractMessage(body, 'Member loaded'),
            member: member,
          );
        }
      }

      debugPrint('MemberService.fetchMemberById -> ${response.statusCode}');
      return (
        success: false,
        message: _extractMessage(
          body,
          'Could not load member details (${response.statusCode}).',
        ),
        member: null,
      );
    } on AppException catch (e) {
      return (
        success: false,
        message: e.message == AppStrings.noInternetConnection
            ? 'No internet connection. Please check your network and try again.'
            : 'Could not reach the server. Please try again.',
        member: null,
      );
    } catch (e) {
      debugPrint('MemberService.fetchMemberById error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        member: null,
      );
    }
  }

  /// GET /users/{user_id}/availability (authenticated) — fetches user availability status.
  Future<({bool success, String message, UserAvailability? availability})>
      fetchUserAvailability(String userId) async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.getUserAvailability(userId));

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final availability = UserAvailability.fromJson(body);
        return (
          success: true,
          message: _extractMessage(body, 'Availability loaded'),
          availability: availability,
        );
      }

      debugPrint(
          'MemberService.fetchUserAvailability -> ${response.statusCode}');
      return (
        success: false,
        message: _extractMessage(
          body,
          'Could not load availability (${response.statusCode}).',
        ),
        availability: null,
      );
    } on AppException catch (e) {
      return (
        success: false,
        message: e.message == AppStrings.noInternetConnection
            ? 'No internet connection. Please check your network and try again.'
            : 'Could not reach the server. Please try again.',
        availability: null,
      );
    } catch (e) {
      debugPrint('MemberService.fetchUserAvailability error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        availability: null,
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
