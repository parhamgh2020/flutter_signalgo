import '../../../../core/error/result.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';

class NewsRepositoryMock implements NewsRepository {
  final _articles = _seed();

  static List<NewsEntity> _seed() {
    final now = DateTime.now();
    const items = [
      (
        'Bitcoin Breaks Key Resistance as ETF Inflows Accelerate',
        'بیت‌کوین با تسریع ورود سرمایه صندوق‌های ETF از مقاومت کلیدی عبور کرد',
        'Bitcoin pushed through a multi-week resistance level as institutional ETF inflows '
            'hit a two-month high, with analysts pointing to renewed macro risk appetite.',
        'بیت‌کوین با ورود سرمایه نهادی صندوق‌های ETF به بالاترین سطح دو ماه اخیر، از سطح مقاومتی '
            'چند هفته‌ای عبور کرد و تحلیلگران آن را به افزایش ریسک‌پذیری کلان نسبت می‌دهند.',
        'CoinDesk',
        ['bitcoin', 'markets'],
        true,
      ),
      (
        'Ethereum Layer-2 Activity Hits All-Time High',
        'فعالیت لایه دوم اتریوم به بالاترین سطح تاریخ رسید',
        'Daily transactions across major Ethereum L2 networks surpassed mainnet volume for '
            'the first time, driven by lower fees and growing DeFi usage.',
        'برای اولین بار، تراکنش‌های روزانه در شبکه‌های لایه دوم اتریوم از حجم شبکه اصلی پیشی گرفت که '
            'به دلیل کارمزد پایین‌تر و افزایش استفاده از دیفای است.',
        'The Block',
        ['ethereum', 'defi'],
        true,
      ),
      (
        'Solana Ecosystem Sees Surge in New Token Launches',
        'اکوسیستم سولانا شاهد افزایش عرضه توکن‌های جدید است',
        'A wave of new token launches on Solana pushed network fees higher this week, '
            'even as validators report record throughput with no major outages.',
        'موجی از عرضه توکن‌های جدید در سولانا این هفته کارمزد شبکه را افزایش داد، در حالی که '
            'اعتبارسنج‌ها گزارش دادند توان عملیاتی بدون اختلال جدی به رکورد رسیده است.',
        'Decrypt',
        ['solana', 'markets'],
        false,
      ),
      (
        'Regulators Signal Clearer Stablecoin Framework',
        'نهادهای ناظر از چارچوب شفاف‌تر برای استیبل‌کوین‌ها خبر دادند',
        'A draft framework circulating among regulators would set reserve and disclosure '
            'requirements for stablecoin issuers, easing uncertainty for exchanges.',
        'پیش‌نویس چارچوبی در حال بررسی توسط نهادهای ناظر، الزامات ذخیره و افشای اطلاعات را برای '
            'صادرکنندگان استیبل‌کوین مشخص می‌کند که ابهام صرافی‌ها را کاهش می‌دهد.',
        'Reuters',
        ['regulation'],
        false,
      ),
      (
        'On-Chain Data Shows Long-Term Holders Accumulating',
        'داده‌های آن-چین نشان می‌دهد نگهدارندگان بلندمدت در حال انباشت هستند',
        'Wallets holding coins for over a year added to their positions during the recent '
            'dip, a pattern historically associated with market bottoms.',
        'کیف‌پول‌هایی که بیش از یک سال ارز نگه داشته‌اند در افت اخیر بازار بر حجم دارایی خود افزودند؛ '
            'الگویی که در گذشته با کف‌های بازار همراه بوده است.',
        'Glassnode Insights',
        ['on-chain', 'bitcoin'],
        false,
      ),
    ];

    return [
      for (var i = 0; i < items.length; i++)
        NewsEntity(
          id: 'news_$i',
          titleEn: items[i].$1,
          titleFa: items[i].$2,
          bodyEn: items[i].$3,
          bodyFa: items[i].$4,
          source: items[i].$5,
          imageUrl: null,
          url: 'https://example.com/news/$i',
          tags: items[i].$6,
          publishedAt: now.subtract(Duration(hours: i * 5 + 1)),
          isFeatured: items[i].$7,
        ),
    ];
  }

  @override
  Future<Result<NewsPage>> fetchNews({
    int limit = 20,
    String? cursor,
    String? tag,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var items = List<NewsEntity>.from(_articles)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    if (tag != null && tag.isNotEmpty) {
      items = items.where((n) => n.tags.contains(tag)).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      items = items.where((n) => n.titleEn.toLowerCase().contains(q)).toList();
    }
    final startIndex = cursor == null ? 0 : items.indexWhere((n) => n.id == cursor) + 1;
    final page = items.skip(startIndex).take(limit).toList();
    return Ok(NewsPage(
      items: page,
      nextCursor: startIndex + page.length < items.length ? page.last.id : null,
    ));
  }

  @override
  Future<Result<List<NewsEntity>>> fetchFeatured() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Ok(_articles.where((n) => n.isFeatured).toList());
  }
}
