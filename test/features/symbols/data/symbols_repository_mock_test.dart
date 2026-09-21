import 'package:flutter_test/flutter_test.dart';
import 'package:signalgo/core/error/result.dart';
import 'package:signalgo/features/symbols/data/repositories/symbols_repository_mock.dart';
import 'package:signalgo/features/symbols/domain/repositories/symbols_repository.dart';

void main() {
  group('SymbolsRepositoryMock', () {
    late SymbolsRepositoryMock repository;

    setUp(() => repository = SymbolsRepositoryMock());

    test('fetchSymbols returns a page sorted by market cap by default', () async {
      final result = await repository.fetchSymbols(limit: 5);
      final page = (result as Ok<SymbolsPage>).value;

      expect(page.items.length, 5);
      for (var i = 0; i < page.items.length - 1; i++) {
        expect(page.items[i].marketCap, greaterThanOrEqualTo(page.items[i + 1].marketCap));
      }
      expect(page.nextCursor, isNotNull);
    });

    test('fetchSymbols paginates via cursor without duplicates', () async {
      final firstResult = await repository.fetchSymbols(limit: 3);
      final firstPage = (firstResult as Ok<SymbolsPage>).value;

      final secondResult = await repository.fetchSymbols(limit: 3, cursor: firstPage.nextCursor);
      final secondPage = (secondResult as Ok<SymbolsPage>).value;

      final firstIds = firstPage.items.map((e) => e.id).toSet();
      final secondIds = secondPage.items.map((e) => e.id).toSet();
      expect(firstIds.intersection(secondIds), isEmpty);
    });

    test('fetchSymbols filters by search query', () async {
      final result = await repository.fetchSymbols(search: 'bitcoin');
      final page = (result as Ok<SymbolsPage>).value;

      expect(page.items, isNotEmpty);
      expect(
        page.items.every((s) =>
            s.name.toLowerCase().contains('bitcoin') || s.symbol.toLowerCase().contains('bitcoin')),
        isTrue,
      );
    });

    test('fetchSymbols sorts gainers and losers correctly', () async {
      final gainersResult = await repository.fetchSymbols(sort: SymbolSort.gainers);
      final gainers = (gainersResult as Ok<SymbolsPage>).value.items;
      for (var i = 0; i < gainers.length - 1; i++) {
        expect(gainers[i].change24h, greaterThanOrEqualTo(gainers[i + 1].change24h));
      }

      final losersResult = await repository.fetchSymbols(sort: SymbolSort.losers);
      final losers = (losersResult as Ok<SymbolsPage>).value.items;
      for (var i = 0; i < losers.length - 1; i++) {
        expect(losers[i].change24h, lessThanOrEqualTo(losers[i + 1].change24h));
      }
    });

    test('watchPriceUpdates emits a live update for a known symbol', () async {
      await repository.fetchSymbols();
      final update = await repository.watchPriceUpdates().first;
      expect(update.id, isNotEmpty);
      expect(update.price, greaterThan(0));
    });
  });
}
