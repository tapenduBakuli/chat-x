import 'package:flutter/services.dart';

/// Formats card expiry input as `MM/YY` while typing.
///
/// - Keeps digits only, max 4 (MMYY).
/// - Auto-inserts "/" once the 2-digit month is entered ("09" -> "09/").
/// - A single first digit 2-9 is treated as a month and zero-padded
///   ("9" -> "09/"), since no month starts with 2-9 as a two-digit value.
/// - Backspacing over the auto "/" removes the last month digit, so deleting
///   feels natural instead of getting stuck on the slash.
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // User deleted the auto-inserted slash ("09/" -> "09"): drop a month digit.
    final bool deleting = newValue.text.length < oldValue.text.length;
    if (deleting &&
        oldValue.text.endsWith('/') &&
        !newValue.text.contains('/') &&
        digits.length == 2) {
      digits = digits.substring(0, 1);
    }

    // "9" -> "09" (months 2-9 can only be single-digit months).
    if (!deleting && digits.length == 1 && int.parse(digits) > 1) {
      digits = '0$digits';
    }

    if (digits.length > 4) digits = digits.substring(0, 4);

    String formatted;
    if (digits.length >= 2) {
      final month = digits.substring(0, 2);
      final year = digits.substring(2);
      // Add the slash as soon as the month is complete (while typing forward).
      formatted = (year.isEmpty && deleting) ? month : '$month/$year';
    } else {
      formatted = digits;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
