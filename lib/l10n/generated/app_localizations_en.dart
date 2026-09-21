// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SignalGo';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading…';

  @override
  String get seeAll => 'See all';

  @override
  String get close => 'Close';

  @override
  String get offline => 'You\'re offline';

  @override
  String get offlineBanner => 'No connection — showing last saved data';

  @override
  String get navSymbols => 'Symbols';

  @override
  String get navChart => 'Chart';

  @override
  String get navNews => 'News';

  @override
  String get navSettings => 'Settings';

  @override
  String get symbolsTitle => 'Symbols';

  @override
  String get searchHint => 'Search coins…';

  @override
  String get sortMarketCap => 'Market cap';

  @override
  String get sortGainers => 'Top gainers';

  @override
  String get sortLosers => 'Top losers';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get emptyWatchlist => 'Your watchlist is empty';

  @override
  String get emptyWatchlistHint => 'Tap the star on any coin to add it here';

  @override
  String get emptySymbols => 'No symbols found';

  @override
  String get priceLabel => 'Price';

  @override
  String get change24hLabel => '24h';

  @override
  String get change7dLabel => '7d';

  @override
  String get marketCapLabel => 'Market Cap';

  @override
  String get volume24hLabel => '24h Volume';

  @override
  String rankLabel(int rank) {
    return 'Rank #$rank';
  }

  @override
  String get chartTitle => 'Chart & Analysis';

  @override
  String get timeframe1h => '1H';

  @override
  String get timeframe4h => '4H';

  @override
  String get timeframe1d => '1D';

  @override
  String get timeframe1w => '1W';

  @override
  String get indicatorMA => 'MA';

  @override
  String get indicatorRSI => 'RSI';

  @override
  String get indicatorMACD => 'MACD';

  @override
  String get trendLabel => 'Trend';

  @override
  String get trendBullish => 'Bullish';

  @override
  String get trendBearish => 'Bearish';

  @override
  String get trendSideways => 'Sideways';

  @override
  String get signalBuy => 'Buy';

  @override
  String get signalSell => 'Sell';

  @override
  String get signalNeutral => 'Neutral';

  @override
  String confidenceLabel(int value) {
    return 'Confidence $value%';
  }

  @override
  String get supportLevels => 'Support';

  @override
  String get resistanceLevels => 'Resistance';

  @override
  String get selectSymbol => 'Select symbol';

  @override
  String get analysisSummary => 'Analysis';

  @override
  String get noAnalysisAvailable =>
      'No analysis available for this timeframe yet';

  @override
  String get chooseCoinFirst => 'Choose a coin to see its chart';

  @override
  String get newsTitle => 'News';

  @override
  String get btcDominance => 'BTC Dominance';

  @override
  String get fearGreedIndex => 'Fear & Greed';

  @override
  String get topGainers => 'Top Gainers';

  @override
  String get topLosers => 'Top Losers';

  @override
  String get featured => 'Featured';

  @override
  String get readMore => 'Read more';

  @override
  String get share => 'Share';

  @override
  String get openOriginal => 'Open original';

  @override
  String publishedAgo(String time) {
    return 'Published $time';
  }

  @override
  String get emptyNews => 'No news yet';

  @override
  String get allTags => 'All';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get persian => 'فارسی';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get displayCurrency => 'Display currency';

  @override
  String get usd => 'USD';

  @override
  String get irt => 'Toman (IRT)';

  @override
  String get persianDigits => 'Persian digits';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifPriceAlerts => 'Price alerts';

  @override
  String get notifNewsAlerts => 'Breaking news';

  @override
  String get account => 'Account';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get anonymousAccount => 'Anonymous session';

  @override
  String get syncWatchlist => 'Sync watchlist across devices';

  @override
  String get about => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get backendStatus => 'Backend status';

  @override
  String get backendOnline => 'Online';

  @override
  String get backendOffline => 'Unreachable';

  @override
  String get backendChecking => 'Checking…';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Can\'t reach the server. Check your connection.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String errorAppwrite(String message) {
    return 'Server error: $message';
  }

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorSelfSignedCert => 'Couldn\'t verify the server certificate.';
}
