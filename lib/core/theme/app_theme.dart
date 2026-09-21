import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Modern fintech aesthetic, dark-first. `fa` locale gets Vazirmatn applied
/// on top of whichever mode is active (see `localizedTextTheme` usage in
/// `main.dart`).
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _base(Brightness.dark, AppColors.seedDark);
  static ThemeData light() => _base(Brightness.light, AppColors.seedLight);

  static ThemeData _base(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Applies the Vazirmatn font family on top of a base [ThemeData] for the
  /// `fa` locale, keeping the Latin theme's shapes/colors untouched.
  static ThemeData withFarsiFont(ThemeData base) {
    final textTheme = GoogleFonts.vazirmatnTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.vazirmatnTextTheme(base.primaryTextTheme),
    );
  }
}
