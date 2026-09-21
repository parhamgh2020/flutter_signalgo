import 'package:flutter/material.dart';

/// Semantic gain/loss colors, deliberately locale-independent — only the
/// +/- sign and arrow glyph mirror under RTL, never the color itself.
class AppColors {
  AppColors._();

  static const gain = Color(0xFF16C784);
  static const loss = Color(0xFFEA3943);
  static const neutral = Color(0xFF8A8FA3);

  static const seedDark = Color(0xFF3E7BFA);
  static const seedLight = Color(0xFF2A5FD8);
}
