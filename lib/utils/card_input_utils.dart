import 'package:flutter/services.dart';

/// Pure card-entry helpers (no GetX / Hive) shared by the Accounts payment
/// modal. The onboarding Payment screen is intentionally untouched.

/// Removes everything but digits (spaces, dashes...).
String stripCardNumber(String input) => input.replaceAll(RegExp(r'\D'), '');

/// Groups digits by 4 while typing (max 19 digits) and keeps the cursor at the
/// end.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = stripCardNumber(newValue.text);
    if (digits.length > 19) digits = digits.substring(0, 19);
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) out.write(' ');
      out.write(digits[i]);
    }
    final String text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String? validateCardholderName(String input) =>
    input.trim().isEmpty ? 'Enter the cardholder name.' : null;

/// 13–19 digits once spaces are stripped. No Luhn (onboarding doesn't use it).
String? validateCardNumber(String input) {
  final int n = stripCardNumber(input).length;
  if (n < 13 || n > 19) return 'Enter a valid card number (13–19 digits).';
  return null;
}

/// 3–4 digits.
String? validateCvv(String input) {
  if (!RegExp(r'^\d{3,4}$').hasMatch(input.trim())) {
    return 'Enter a valid CVV/CVC (3–4 digits).';
  }
  return null;
}

/// Month 1–12 and not before the current month.
String? validateExpiry(int? month, int? year, {DateTime? now}) {
  if (month == null || year == null) return 'Select the card expiry.';
  if (month < 1 || month > 12) return 'Select a valid expiry month.';
  final DateTime n = now ?? DateTime.now();
  if (year < n.year || (year == n.year && month < n.month)) {
    return 'This card has expired.';
  }
  return null;
}

/// Current year … current year + 15.
List<int> expiryYearOptions({DateTime? now}) {
  final int y = (now ?? DateTime.now()).year;
  return List<int>.generate(16, (i) => y + i);
}

/// "MM / YYYY", zero-padded month.
String formatExpiry(int month, int year) =>
    '${month.toString().padLeft(2, '0')} / $year';
