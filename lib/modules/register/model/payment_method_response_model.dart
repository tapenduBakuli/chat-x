/// Response model for POST /users/me/payment-method.
///
/// Server shape:
/// {
///   "success": bool,
///   "message": string,
///   "data": {
///     "id": string,
///     "masked_card_number": string,
///     "cardholder_name": string,
///     "expiry_month": int,
///     "expiry_year": int,
///     "created_at": string
///   }
/// }
class PaymentMethodResponseModel {
  final bool success;
  final String message;
  final PaymentMethodData? data;

  const PaymentMethodResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentMethodResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? PaymentMethodData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentMethodData {
  final String id;
  final String maskedCardNumber;
  final String cardholderName;
  final int expiryMonth;
  final int expiryYear;
  final String createdAt;

  const PaymentMethodData({
    required this.id,
    required this.maskedCardNumber,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.createdAt,
  });

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) {
    return PaymentMethodData(
      id: (json['id'] ?? '').toString(),
      maskedCardNumber: (json['masked_card_number'] ?? '').toString(),
      cardholderName: (json['cardholder_name'] ?? '').toString(),
      expiryMonth: json['expiry_month'] is int
          ? json['expiry_month'] as int
          : int.tryParse('${json['expiry_month']}') ?? 0,
      expiryYear: json['expiry_year'] is int
          ? json['expiry_year'] as int
          : int.tryParse('${json['expiry_year']}') ?? 0,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}
