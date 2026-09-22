import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appwrite/health_service.dart';
import '../../../core/providers/locale_controller.dart';
import '../../../core/providers/package_info_provider.dart';
import '../../../core/providers/theme_controller.dart';
import '../../../core/settings/app_currency.dart';
import '../../../core/viewmodels/auth_view_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/sign_in_sheet.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final currency = ref.watch(displayCurrencyViewModelProvider);
    final persianDigits = ref.watch(persianDigitsViewModelProvider);
    final notifPrefs = ref.watch(notificationPrefsViewModelProvider);
    final userAsync = ref.watch(authViewModelProvider);
    final backendAsync = ref.watch(backendStatusProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(l10n.language),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<Locale>(
              segments: [
                ButtonSegment(value: const Locale('en'), label: Text(l10n.english)),
                ButtonSegment(value: const Locale('fa'), label: Text(l10n.persian)),
              ],
              selected: {locale},
              onSelectionChanged: (s) => ref.read(localeControllerProvider.notifier).setLocale(s.first),
            ),
          ),
          _SectionHeader(l10n.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => ref.read(themeModeControllerProvider.notifier).setThemeMode(s.first),
            ),
          ),
          _SectionHeader(l10n.displayCurrency),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppCurrency>(
              segments: [
                ButtonSegment(value: AppCurrency.usd, label: Text(l10n.usd)),
                ButtonSegment(value: AppCurrency.irt, label: Text(l10n.irt)),
              ],
              selected: {currency},
              onSelectionChanged: (s) => ref.read(displayCurrencyViewModelProvider.notifier).set(s.first),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.persianDigits),
            value: persianDigits,
            onChanged: (v) => ref.read(persianDigitsViewModelProvider.notifier).set(v),
          ),
          _SectionHeader(l10n.notifications),
          SwitchListTile(
            title: Text(l10n.notifPriceAlerts),
            value: notifPrefs.priceAlerts,
            onChanged: (v) => ref.read(notificationPrefsViewModelProvider.notifier).setPriceAlerts(v),
          ),
          SwitchListTile(
            title: Text(l10n.notifNewsAlerts),
            value: notifPrefs.newsAlerts,
            onChanged: (v) => ref.read(notificationPrefsViewModelProvider.notifier).setNewsAlerts(v),
          ),
          _SectionHeader(l10n.account),
          userAsync.when(
            loading: () => const ListTile(leading: CircularProgressIndicator(), title: Text('')),
            error: (_, _) => ListTile(title: Text(l10n.errorGeneric)),
            data: (user) {
              if (user == null) return ListTile(title: Text(l10n.errorGeneric));
              if (user.isAnonymous) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(l10n.anonymousAccount),
                      subtitle: Text(l10n.syncWatchlist),
                      trailing: FilledButton(
                        onPressed: () => showSignInSheet(context, ref),
                        child: Text(l10n.signIn),
                      ),
                    ),
                  ],
                );
              }
              return ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: Text(l10n.signedInAs(user.email ?? '')),
                subtitle: Text(l10n.syncWatchlist),
                trailing: OutlinedButton(
                  onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
                  child: Text(l10n.signOut),
                ),
              );
            },
          ),
          _SectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.versionLabel(packageInfoAsync.valueOrNull?.version ?? '—')),
          ),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(l10n.backendStatus),
            trailing: backendAsync.when(
              loading: () => Text(l10n.backendChecking),
              error: (_, _) => Text(l10n.backendOffline, style: const TextStyle(color: Colors.red)),
              data: (status) => Text(
                status == BackendStatus.online ? l10n.backendOnline : l10n.backendOffline,
                style: TextStyle(color: status == BackendStatus.online ? Colors.green : Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
      ),
    );
  }
}
