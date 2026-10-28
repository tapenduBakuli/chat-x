import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/payment_method_response_model.dart';

/// Network layer for saving the user's payment method. Mirrors [LoginService]:
/// wraps [BaseClient] so the controller stays free of HTTP/JSON details.
class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  /// POST /users/me/payment-method — saves a credit-card payment method.
  ///
  /// Note: this is an AUTHENTICATED call, so [isAuth] is left at its default
  /// (false) and [BaseClient] attaches the bearer token from the stored
  /// session/registration token.
  Future<PaymentMethodResponseModel> saveCardPaymentMethod({
    required String cardNumber,
    required String cardholderName,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
  }) async {
    try {
      final http.Response response = await BaseClient.instance.post(
        Urls.savePaymentMethod,
        {
          "card_number": cardNumber,
          "cardholder_name": cardholderName,
          "expiry_month": expiryMonth,
          "expiry_year": expiryYear,
          "cvv": cvv,
        },
      );

      final dynamic body = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : <String, dynamic>{};

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map<String, dynamic>) {
        return PaymentMethodResponseModel.fromJson(body);
      }

      return PaymentMethodResponseModel(
        success: false,
        message: _extractMessage(
          body,
          'Could not save payment (${response.statusCode}).',
        ),
      );
    } on AppException catch (e) {
      return PaymentMethodResponseModel(
        success: false,
        message: _messageForAppException(e),
      );
    } catch (e) {
      debugPrint('PaymentService.saveCardPaymentMethod error: $e');
      return const PaymentMethodResponseModel(
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
