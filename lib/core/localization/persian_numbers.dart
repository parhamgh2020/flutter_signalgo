const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Converts ASCII digits in [input] to Persian (Eastern Arabic-Indic)
/// digits. Used when the user enables the "Persian digits" display toggle,
/// independently of locale — some fa-locale users still prefer Latin digits.
String toPersianDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buffer.write(_persianDigits[rune - 0x30]);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}
