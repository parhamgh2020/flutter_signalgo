import 'dart:async';
import 'dart:math';

import '../../../../core/error/result.dart';
import '../../domain/entities/symbol_entity.dart';
import '../../domain/repositories/symbols_repository.dart';

class SymbolsRepositoryMock implements SymbolsRepository {
  SymbolsRepositoryMock() : _symbols = _seed();

  final List<SymbolEntity> _symbols;
  final _random = Random(7);

  static List<SymbolEntity> _seed() {
    final now = DateTime.now();
    const seed = [
      ('BTC', 'Bitcoin', 'بیت‌کوین', 67340.12, 2.34, -1.2, 1.32e12, 28.4e9),
      ('ETH', 'Ethereum', 'اتریوم', 3512.88, -0.87, 4.1, 421e9, 14.1e9),
      ('SOL', 'Solana', 'سولانا', 178.22, 5.62, 12.4, 82e9, 4.2e9),
      ('BNB', 'BNB', 'بی‌ان‌بی', 592.10, 1.05, -0.4, 88e9, 1.8e9),
      ('XRP', 'XRP', 'ریپل', 0.612, -2.11, -5.3, 34e9, 1.1e9),
      ('ADA', 'Cardano', 'کاردانو', 0.451, 0.92, 3.0, 16e9, 420e6),
      ('DOGE', 'Dogecoin', 'دوج‌کوین', 0.152, 3.44, 9.8, 22e9, 1.5e9),
      ('AVAX', 'Avalanche', 'آوالانچ', 34.7, -1.9, -3.4, 13e9, 380e6),
      ('DOT', 'Polkadot', 'پولکادات', 6.83, 0.31, -1.1, 9.6e9, 210e6),
      ('LINK', 'Chainlink', 'چین‌لینک', 14.92, 2.02, 6.7, 8.7e9, 460e6),
      ('MATIC', 'Polygon', 'پالیگان', 0.734, -0.55, -2.2, 7.1e9, 290e6),
      ('LTC', 'Litecoin', 'لایت‌کوین', 83.4, 1.18, 0.9, 6.2e9, 380e6),
    ];

    return [
      for (var i = 0; i < seed.length; i++)
        SymbolEntity(
          id: 'sym_${seed[i].$1.toLowerCase()}',
          symbol: seed[i].$1,
          name: seed[i].$2,
          nameFa: seed[i].$3,
          iconUrl: null,
          price: seed[i].$4,
          change24h: seed[i].$5,
          change7d: seed[i].$6,
          marketCap: seed[i].$7,
          volume24h: seed[i].$8,
          rank: i + 1,
          updatedAt: now,
          sparkline: _fakeSparkline(seed[i].$4, seed[i].$5),
        ),
    ];
  }

  static List<double> _fakeSparkline(double price, double change24h) {
    final start = price / (1 + change24h / 100);
    final rnd = Random(price.hashCode);
    return [
      for (var i = 0; i <= 12; i++)
        start + (price - start) * (i / 12) + (rnd.nextDouble() - 0.5) * price * 0.01,
    ];
  }

  @override
  Future<Result<SymbolsPage>> fetchSymbols({
    int limit = 30,
    String? cursor,
    SymbolSort sort = SymbolSort.marketCap,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    var items = List<SymbolEntity>.from(_symbols);
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      items = items
          .where((s) => s.symbol.toLowerCase().contains(q) || s.name.toLowerCase().contains(q))
          .toList();
    }
    items.sort((a, b) => switch (sort) {
          SymbolSort.marketCap => b.marketCap.compareTo(a.marketCap),
          SymbolSort.gainers => b.change24h.compareTo(a.change24h),
          SymbolSort.losers => a.change24h.compareTo(b.change24h),
        });

    final startIndex = cursor == null ? 0 : items.indexWhere((s) => s.id == cursor) + 1;
    final page = items.skip(startIndex).take(limit).toList();

    return Ok(SymbolsPage(
      items: page,
      nextCursor: startIndex + page.length < items.length ? page.last.id : null,
    ));
  }

  @override
  Stream<SymbolEntity> watchPriceUpdates() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      final target = _symbols[_random.nextInt(_symbols.length)];
      final index = _symbols.indexOf(target);
      final drift = (_random.nextDouble() - 0.5) * 0.006;
      final updated = target.copyWithLiveUpdate(
        price: target.price * (1 + drift),
        change24h: target.change24h + drift * 100,
      );
      _symbols[index] = updated;
      yield updated;
    }
  }
}
