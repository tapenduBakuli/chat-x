import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../../register/model/payment_method_response_model.dart';
import '../model/subscription_info.dart';

/// Extracts the saved card from a GET users/me/payment-method body. Returns
/// null when there is none (`data` missing / null / not a map).
PaymentMethodData? parsePaymentMethodBody(dynamic body) {
  if (body is Map && body['data'] is Map) {
    return PaymentMethodData.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }
  return null;
}

/// Network layer for the Accounts tab billing cards. Never throws; failures
/// come back with `success: false` and a friendly message. Saving a card is
/// done by [PaymentService.saveCardPaymentMethod].
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  /// GET subscriptions/me.
  Future<({bool success, String message, SubscriptionInfo? data})>
      fetchSubscription() async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.mySubscription);
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map && body['data'] is Map) {
        return (
          success: true,
          message: '',
          data: SubscriptionInfo.fromJson(
            Map<String, dynamic>.from(body['data'] as Map),
          ),
        );
      }
      return (
        success: false,
        message: _extractMessage(body, 'Could not load subscription ($code).'),
        data: null,
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e), data: null);
    } catch (e) {
      debugPrint('BillingService.fetchSubscription error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
      );
    }
  }

  /// GET users/me/payment-method. 404 or empty `data` is "no card" (success).
  Future<({bool success, String message, PaymentMethodData? data})>
      fetchPaymentMethod() async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.myPaymentMethod);
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 404) return (success: true, message: '', data: null);
      if (code == 200) {
        return (
          success: true,
          message: '',
          data: parsePaymentMethodBody(body),
        );
      }
      return (
        success: false,
        message:
            _extractMessage(body, 'Could not load payment method ($code).'),
        data: null,
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e), data: null);
    } catch (e) {
      debugPrint('BillingService.fetchPaymentMethod error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
      );
    }
  }

  /// DELETE users/me/payment-method (200/202/204 = success).
  Future<({bool success, String message})> deletePaymentMethod() async {
    try {
      final http.Response response = await BaseClient.instance
          .delete(Urls.myPaymentMethod, <String, dynamic>{});
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 || code == 202 || code == 204) {
        final String msg =
            body is Map && body['message'] != null ? '${body['message']}' : '';
        return (success: true, message: msg);
      }
      return (
        success: false,
        message:
            _extractMessage(body, 'Could not delete payment method ($code).'),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('BillingService.deletePaymentMethod error: $e');
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

  String _offlineMessage(AppException e) =>
      e.message == AppStrings.noInternetConnection
          ? 'No internet connection. Please check your network and try again.'
          : 'Could not reach the server. Please try again.';

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
