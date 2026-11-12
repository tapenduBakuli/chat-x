import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/report_model.dart';

/// Network layer for loading report reasons and submitting user reports.
class ReportService {
  ReportService._();

  static final ReportService instance = ReportService._();

  /// GET /reports/reasons (authenticated) — fetches available report reasons.
  Future<({bool success, String message, List<ReportReason> reasons})>
      fetchReasons() async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.reportReasons);

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final data = body['data'];
        final items = <ReportReason>[];
        if (data is Map && data['reasons'] is List) {
          for (final item in data['reasons'] as List) {
            if (item is Map<String, dynamic>) {
              items.add(ReportReason.fromJson(item));
            }
          }
        }
        return (
          success: true,
          message: _extractMessage(body, 'Reasons loaded'),
          reasons: List<ReportReason>.unmodifiable(items),
        );
      }

      return (
        success: false,
        message: _extractMessage(
          body,
          'Could not load report reasons (${response.statusCode}).',
        ),
        reasons: const <ReportReason>[],
      );
    } on AppException catch (e) {
      return (
        success: false,
        message: e.message == AppStrings.noInternetConnection
            ? 'No internet connection. Please check your network and try again.'
            : 'Could not reach the server. Please try again.',
        reasons: const <ReportReason>[],
      );
    } catch (e) {
      debugPrint('ReportService.fetchReasons error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        reasons: const <ReportReason>[],
      );
    }
  }

  /// POST /reports (authenticated) — submits a report for a user.
  Future<({bool success, String message})> submitReport({
    required String reportedUserId,
    required String reasonCode,
    required String reasonText,
  }) async {
    try {
      final payload = <String, dynamic>{
        'reported_user_id': reportedUserId,
        'reason_code': reasonCode,
        'reason_text': reasonText,
      };

      final http.Response response =
          await BaseClient.instance.post(Urls.reports, payload);

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        final String serverMsg =
            body['message']?.toString().trim() ?? 'Report submitted successfully';
        return (
          success: true,
          message: serverMsg.isNotEmpty ? serverMsg : 'Report submitted successfully',
        );
      }

      return (
        success: false,
        message: _extractMessage(
          body,
          'Could not submit report (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return (
        success: false,
        message: e.message == AppStrings.noInternetConnection
            ? 'No internet connection. Please check your network and try again.'
            : 'Could not reach the server. Please try again.',
      );
    } catch (e) {
      debugPrint('ReportService.submitReport error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

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
