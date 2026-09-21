import 'package:flutter/widgets.dart';

/// Backend records store bilingual content as separate `*_en` / `*_fa`
/// fields (e.g. `summary_en` / `summary_fa`). This picks the right one for
/// the active locale, falling back to English when the Farsi field is
/// missing or empty rather than showing blank content.
extension LocalizedFieldLocale on Locale {
  String pick({required String en, String? fa}) {
    if (languageCode == 'fa' && fa != null && fa.trim().isNotEmpty) {
      return fa;
    }
    return en;
  }
}

extension LocalizedFieldContext on BuildContext {
  String localizedField({required String en, String? fa}) {
    return Localizations.localeOf(this).pick(en: en, fa: fa);
  }

  bool get isRtl => Localizations.localeOf(this).languageCode == 'fa';
}
