import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shared_preferences_provider.dart';
import '../../../core/settings/app_currency.dart';

const _currencyKey = 'signalgo.currency';
const _persianDigitsKey = 'signalgo.persian_digits';
const _notifPriceKey = 'signalgo.notif_price_alerts';
const _notifNewsKey = 'signalgo.notif_news_alerts';

class DisplayCurrencyViewModel extends Notifier<AppCurrency> {
  @override
  AppCurrency build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_currencyKey);
    return saved == 'irt' ? AppCurrency.irt : AppCurrency.usd;
  }

  Future<void> set(AppCurrency currency) async {
    state = currency;
    await ref.read(sharedPreferencesProvider).setString(_currencyKey, currency.name);
  }
}

final displayCurrencyViewModelProvider =
    NotifierProvider<DisplayCurrencyViewModel, AppCurrency>(DisplayCurrencyViewModel.new);

class PersianDigitsViewModel extends Notifier<bool> {
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_persianDigitsKey) ?? false;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_persianDigitsKey, value);
  }
}

final persianDigitsViewModelProvider = NotifierProvider<PersianDigitsViewModel, bool>(
  PersianDigitsViewModel.new,
);

class NotificationPrefsViewModel extends Notifier<({bool priceAlerts, bool newsAlerts})> {
  @override
  ({bool priceAlerts, bool newsAlerts}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return (
      priceAlerts: prefs.getBool(_notifPriceKey) ?? true,
      newsAlerts: prefs.getBool(_notifNewsKey) ?? true,
    );
  }

  Future<void> setPriceAlerts(bool value) async {
    state = (priceAlerts: value, newsAlerts: state.newsAlerts);
    await ref.read(sharedPreferencesProvider).setBool(_notifPriceKey, value);
  }

  Future<void> setNewsAlerts(bool value) async {
    state = (priceAlerts: state.priceAlerts, newsAlerts: value);
    await ref.read(sharedPreferencesProvider).setBool(_notifNewsKey, value);
  }
}

final notificationPrefsViewModelProvider =
    NotifierProvider<NotificationPrefsViewModel, ({bool priceAlerts, bool newsAlerts})>(
  NotificationPrefsViewModel.new,
);
