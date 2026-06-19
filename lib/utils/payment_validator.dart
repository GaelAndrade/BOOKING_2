import 'dart:math';

class PaymentValidator {
  PaymentValidator._();

  static String formatExpiration(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final month = digits.substring(0, min(2, digits.length));
    final year = digits.length > 2
        ? digits.substring(2, min(4, digits.length))
        : '';
    return year.isEmpty ? month : '$month/$year';
  }

  static bool isCardNumberValid(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 16;
  }

  static bool isExpirationValid(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value);
    if (match == null) return false;

    final month = int.tryParse(match.group(1)!);
    final year = int.tryParse(match.group(2)!);
    if (month == null || year == null || month < 1 || month > 12) {
      return false;
    }

    final now = DateTime.now();
    final fullYear = 2000 + year;
    final lastValidDay = DateTime(fullYear, month + 1, 0);
    return !lastValidDay.isBefore(DateTime(now.year, now.month, now.day));
  }

  static bool isCvvValid(String value) {
    return RegExp(r'^\d{3}$').hasMatch(value);
  }
}
