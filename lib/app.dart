import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/locale_controller.dart';
import 'core/providers/theme_controller.dart';
import 'core/router/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/viewmodels/auth_view_model.dart';
import 'l10n/generated/app_localizations.dart';

class SignalGoApp extends ConsumerWidget {
  const SignalGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    // Ensures an Appwrite session (anonymous, at minimum) exists as soon as
    // the app starts, independent of which screen the user opens first.
    ref.watch(authViewModelProvider);

    final isFarsi = locale.languageCode == 'fa';
    final light = isFarsi ? AppTheme.withFarsiFont(AppTheme.light()) : AppTheme.light();
    final dark = isFarsi ? AppTheme.withFarsiFont(AppTheme.dark()) : AppTheme.dark();

    return MaterialApp(
      title: 'SignalGo',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      home: const AppShell(),
    );
  }
}
