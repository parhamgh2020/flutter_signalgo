import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_provider.dart';

const _prefsKey = 'signalgo.locale';

/// Persisted app locale. Changing this rebuilds `MaterialApp` with a new
/// `Locale`, which flips `Directionality` (LTR ⇄ RTL) immediately — no
/// restart required.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_prefsKey);
    return switch (saved) {
      'fa' => const Locale('fa'),
      'en' => const Locale('en'),
      _ => const Locale('en'),
    };
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(_prefsKey, locale.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
