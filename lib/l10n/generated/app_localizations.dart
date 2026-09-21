import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'SignalGo'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offline;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection — showing last saved data'**
  String get offlineBanner;

  /// No description provided for @navSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get navSymbols;

  /// No description provided for @navChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get navChart;

  /// No description provided for @navNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get navNews;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @symbolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get symbolsTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search coins…'**
  String get searchHint;

  /// No description provided for @sortMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market cap'**
  String get sortMarketCap;

  /// No description provided for @sortGainers.
  ///
  /// In en, this message translates to:
  /// **'Top gainers'**
  String get sortGainers;

  /// No description provided for @sortLosers.
  ///
  /// In en, this message translates to:
  /// **'Top losers'**
  String get sortLosers;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// No description provided for @emptyWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Your watchlist is empty'**
  String get emptyWatchlist;

  /// No description provided for @emptyWatchlistHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the star on any coin to add it here'**
  String get emptyWatchlistHint;

  /// No description provided for @emptySymbols.
  ///
  /// In en, this message translates to:
  /// **'No symbols found'**
  String get emptySymbols;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @change24hLabel.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get change24hLabel;

  /// No description provided for @change7dLabel.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get change7dLabel;

  /// No description provided for @marketCapLabel.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get marketCapLabel;

  /// No description provided for @volume24hLabel.
  ///
  /// In en, this message translates to:
  /// **'24h Volume'**
  String get volume24hLabel;

  /// No description provided for @rankLabel.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank}'**
  String rankLabel(int rank);

  /// No description provided for @chartTitle.
  ///
  /// In en, this message translates to:
  /// **'Chart & Analysis'**
  String get chartTitle;

  /// No description provided for @timeframe1h.
  ///
  /// In en, this message translates to:
  /// **'1H'**
  String get timeframe1h;

  /// No description provided for @timeframe4h.
  ///
  /// In en, this message translates to:
  /// **'4H'**
  String get timeframe4h;

  /// No description provided for @timeframe1d.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get timeframe1d;

  /// No description provided for @timeframe1w.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get timeframe1w;

  /// No description provided for @indicatorMA.
  ///
  /// In en, this message translates to:
  /// **'MA'**
  String get indicatorMA;

  /// No description provided for @indicatorRSI.
  ///
  /// In en, this message translates to:
  /// **'RSI'**
  String get indicatorRSI;

  /// No description provided for @indicatorMACD.
  ///
  /// In en, this message translates to:
  /// **'MACD'**
  String get indicatorMACD;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @trendBullish.
  ///
  /// In en, this message translates to:
  /// **'Bullish'**
  String get trendBullish;

  /// No description provided for @trendBearish.
  ///
  /// In en, this message translates to:
  /// **'Bearish'**
  String get trendBearish;

  /// No description provided for @trendSideways.
  ///
  /// In en, this message translates to:
  /// **'Sideways'**
  String get trendSideways;

  /// No description provided for @signalBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get signalBuy;

  /// No description provided for @signalSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get signalSell;

  /// No description provided for @signalNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get signalNeutral;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence {value}%'**
  String confidenceLabel(int value);

  /// No description provided for @supportLevels.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportLevels;

  /// No description provided for @resistanceLevels.
  ///
  /// In en, this message translates to:
  /// **'Resistance'**
  String get resistanceLevels;

  /// No description provided for @selectSymbol.
  ///
  /// In en, this message translates to:
  /// **'Select symbol'**
  String get selectSymbol;

  /// No description provided for @analysisSummary.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisSummary;

  /// No description provided for @noAnalysisAvailable.
  ///
  /// In en, this message translates to:
  /// **'No analysis available for this timeframe yet'**
  String get noAnalysisAvailable;

  /// No description provided for @chooseCoinFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a coin to see its chart'**
  String get chooseCoinFirst;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTitle;

  /// No description provided for @btcDominance.
  ///
  /// In en, this message translates to:
  /// **'BTC Dominance'**
  String get btcDominance;

  /// No description provided for @fearGreedIndex.
  ///
  /// In en, this message translates to:
  /// **'Fear & Greed'**
  String get fearGreedIndex;

  /// No description provided for @topGainers.
  ///
  /// In en, this message translates to:
  /// **'Top Gainers'**
  String get topGainers;

  /// No description provided for @topLosers.
  ///
  /// In en, this message translates to:
  /// **'Top Losers'**
  String get topLosers;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @openOriginal.
  ///
  /// In en, this message translates to:
  /// **'Open original'**
  String get openOriginal;

  /// No description provided for @publishedAgo.
  ///
  /// In en, this message translates to:
  /// **'Published {time}'**
  String publishedAgo(String time);

  /// No description provided for @emptyNews.
  ///
  /// In en, this message translates to:
  /// **'No news yet'**
  String get emptyNews;

  /// No description provided for @allTags.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTags;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @persian.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get persian;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @irt.
  ///
  /// In en, this message translates to:
  /// **'Toman (IRT)'**
  String get irt;

  /// No description provided for @persianDigits.
  ///
  /// In en, this message translates to:
  /// **'Persian digits'**
  String get persianDigits;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifPriceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get notifPriceAlerts;

  /// No description provided for @notifNewsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Breaking news'**
  String get notifNewsAlerts;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @anonymousAccount.
  ///
  /// In en, this message translates to:
  /// **'Anonymous session'**
  String get anonymousAccount;

  /// No description provided for @syncWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Sync watchlist across devices'**
  String get syncWatchlist;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @backendStatus.
  ///
  /// In en, this message translates to:
  /// **'Backend status'**
  String get backendStatus;

  /// No description provided for @backendOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get backendOnline;

  /// No description provided for @backendOffline.
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get backendOffline;

  /// No description provided for @backendChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get backendChecking;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorAppwrite.
  ///
  /// In en, this message translates to:
  /// **'Server error: {message}'**
  String errorAppwrite(String message);

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorSelfSignedCert.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify the server certificate.'**
  String get errorSelfSignedCert;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
