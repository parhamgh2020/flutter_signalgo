// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'سیگنال‌گو';

  @override
  String get retry => 'تلاش دوباره';

  @override
  String get cancel => 'انصراف';

  @override
  String get ok => 'تأیید';

  @override
  String get save => 'ذخیره';

  @override
  String get search => 'جستجو';

  @override
  String get loading => 'در حال بارگذاری…';

  @override
  String get seeAll => 'مشاهده همه';

  @override
  String get close => 'بستن';

  @override
  String get offline => 'شما آفلاین هستید';

  @override
  String get offlineBanner => 'اتصال برقرار نیست — نمایش آخرین داده ذخیره‌شده';

  @override
  String get navSymbols => 'نمادها';

  @override
  String get navChart => 'نمودار';

  @override
  String get navNews => 'اخبار';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get symbolsTitle => 'نمادها';

  @override
  String get searchHint => 'جستجوی ارز…';

  @override
  String get sortMarketCap => 'ارزش بازار';

  @override
  String get sortGainers => 'بیشترین رشد';

  @override
  String get sortLosers => 'بیشترین افت';

  @override
  String get filterFavorites => 'موردعلاقه‌ها';

  @override
  String get emptyWatchlist => 'لیست موردعلاقه‌های شما خالی است';

  @override
  String get emptyWatchlistHint => 'برای افزودن، ستاره کنار هر ارز را بزنید';

  @override
  String get emptySymbols => 'نمادی یافت نشد';

  @override
  String get priceLabel => 'قیمت';

  @override
  String get change24hLabel => '۲۴ ساعت';

  @override
  String get change7dLabel => '۷ روز';

  @override
  String get marketCapLabel => 'ارزش بازار';

  @override
  String get volume24hLabel => 'حجم ۲۴ ساعت';

  @override
  String rankLabel(int rank) {
    return 'رتبه #$rank';
  }

  @override
  String get chartTitle => 'نمودار و تحلیل';

  @override
  String get timeframe1h => '۱ساعته';

  @override
  String get timeframe4h => '۴ساعته';

  @override
  String get timeframe1d => 'روزانه';

  @override
  String get timeframe1w => 'هفتگی';

  @override
  String get indicatorMA => 'میانگین متحرک';

  @override
  String get indicatorRSI => 'RSI';

  @override
  String get indicatorMACD => 'MACD';

  @override
  String get trendLabel => 'روند';

  @override
  String get trendBullish => 'صعودی';

  @override
  String get trendBearish => 'نزولی';

  @override
  String get trendSideways => 'خنثی';

  @override
  String get signalBuy => 'خرید';

  @override
  String get signalSell => 'فروش';

  @override
  String get signalNeutral => 'خنثی';

  @override
  String confidenceLabel(int value) {
    return 'اطمینان $value٪';
  }

  @override
  String get supportLevels => 'حمایت';

  @override
  String get resistanceLevels => 'مقاومت';

  @override
  String get selectSymbol => 'انتخاب نماد';

  @override
  String get analysisSummary => 'تحلیل';

  @override
  String get noAnalysisAvailable =>
      'هنوز تحلیلی برای این بازه زمانی موجود نیست';

  @override
  String get chooseCoinFirst => 'برای مشاهده نمودار، یک ارز انتخاب کنید';

  @override
  String get newsTitle => 'اخبار';

  @override
  String get btcDominance => 'سلطه بیت‌کوین';

  @override
  String get fearGreedIndex => 'ترس و طمع';

  @override
  String get topGainers => 'بیشترین رشد';

  @override
  String get topLosers => 'بیشترین افت';

  @override
  String get featured => 'ویژه';

  @override
  String get readMore => 'ادامه مطلب';

  @override
  String get share => 'اشتراک‌گذاری';

  @override
  String get openOriginal => 'مشاهده منبع اصلی';

  @override
  String publishedAgo(String time) {
    return 'منتشرشده $time';
  }

  @override
  String get emptyNews => 'هنوز خبری نیست';

  @override
  String get allTags => 'همه';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get language => 'زبان';

  @override
  String get english => 'English';

  @override
  String get persian => 'فارسی';

  @override
  String get theme => 'پوسته';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تیره';

  @override
  String get themeSystem => 'پیش‌فرض سیستم';

  @override
  String get displayCurrency => 'واحد پول نمایشی';

  @override
  String get usd => 'دلار';

  @override
  String get irt => 'تومان';

  @override
  String get persianDigits => 'ارقام فارسی';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get notifPriceAlerts => 'هشدار قیمت';

  @override
  String get notifNewsAlerts => 'اخبار فوری';

  @override
  String get account => 'حساب کاربری';

  @override
  String get signIn => 'ورود';

  @override
  String get signOut => 'خروج';

  @override
  String signedInAs(String email) {
    return 'ورود با $email';
  }

  @override
  String get anonymousAccount => 'نشست مهمان';

  @override
  String get syncWatchlist => 'همگام‌سازی موردعلاقه‌ها بین دستگاه‌ها';

  @override
  String get about => 'درباره';

  @override
  String versionLabel(String version) {
    return 'نسخه $version';
  }

  @override
  String get backendStatus => 'وضعیت سرور';

  @override
  String get backendOnline => 'متصل';

  @override
  String get backendOffline => 'در دسترس نیست';

  @override
  String get backendChecking => 'در حال بررسی…';

  @override
  String get emailLabel => 'ایمیل';

  @override
  String get passwordLabel => 'رمز عبور';

  @override
  String get continueAsGuest => 'ادامه به‌صورت مهمان';

  @override
  String get errorGeneric => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get errorNetwork =>
      'اتصال به سرور برقرار نشد. اتصال اینترنت را بررسی کنید.';

  @override
  String get errorUnauthorized => 'برای ادامه وارد شوید.';

  @override
  String get errorNotFound => 'یافت نشد.';

  @override
  String errorAppwrite(String message) {
    return 'خطای سرور: $message';
  }

  @override
  String get errorInvalidCredentials => 'ایمیل یا رمز عبور نادرست است.';

  @override
  String get errorSelfSignedCert => 'گواهی امنیتی سرور تأیید نشد.';
}
