class CurrencyUtils {
  CurrencyUtils._();

  /// Formats a number as Vietnamese Dong with thousand separators.
  /// Example: 1234567 -> "1.234.567 đ"
  static String formatVND(num value, {bool withSymbol = true}) {
    final bool isNegative = value < 0;
    final int rounded = value.round();
    final int absValue = rounded.abs();
    final String digits = absValue.toString();
    final String separated = _addThousandSeparators(digits);
    final String signed = isNegative ? '-$separated' : separated;
    return withSymbol ? '$signed đ' : signed;
  }

  static String _addThousandSeparators(String digits) {
    if (digits.length <= 3) return digits;
    final StringBuffer buffer = StringBuffer();
    int counter = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write('.');
        counter = 0;
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}


