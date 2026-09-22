import 'package:flutter_test/flutter_test.dart';
import 'package:signalgo/core/error/result.dart';
import 'package:signalgo/features/watchlist/repositories/watchlist_repository_mock.dart';

void main() {
  group('WatchlistRepositoryMock', () {
    test('starts with seeded watchlist symbols', () async {
      final repo = WatchlistRepositoryMock();
      final result = await repo.fetchWatchlistSymbols();
      expect((result as Ok<Set<String>>).value, contains('sym_btc'));
    });

    test('add then remove updates the fetched state', () async {
      final repo = WatchlistRepositoryMock();

      await repo.add('sym_sol');
      final afterAdd = await repo.fetchWatchlistSymbols();
      expect((afterAdd as Ok<Set<String>>).value, contains('sym_sol'));

      await repo.remove('sym_sol');
      final afterRemove = await repo.fetchWatchlistSymbols();
      expect((afterRemove as Ok<Set<String>>).value, isNot(contains('sym_sol')));
    });

    test('watch() emits the current set immediately, then updates on change', () async {
      final repo = WatchlistRepositoryMock();
      final events = <Set<String>>[];
      final sub = repo.watch().listen(events.add);

      await Future.delayed(const Duration(milliseconds: 10));
      await repo.add('sym_ada');
      await Future.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      expect(events.first, contains('sym_btc'));
      expect(events.last, contains('sym_ada'));
    });
  });
}
