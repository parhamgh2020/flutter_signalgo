import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/cache/offline_cache.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/viewmodels/auth_view_model.dart';
import '../../watchlist/viewmodels/watchlist_view_model.dart';
import '../models/symbol_model.dart';
import '../repositories/symbols_repository.dart';
import '../repositories/symbols_repository_appwrite.dart';

final symbolsRepositoryProvider = Provider<SymbolsRepository>((ref) {
  return SymbolsRepositoryAppwrite(
    databases: ref.watch(appwriteDatabasesProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    config: ref.watch(appwriteConfigProvider),
    cache: OfflineCache(ref.watch(cacheBoxProvider)),
  );
});

final symbolSortProvider = StateProvider<SymbolSort>((ref) => SymbolSort.marketCap);
final symbolSearchQueryProvider = StateProvider<String>((ref) => '');
final favoritesOnlyProvider = StateProvider<bool>((ref) => false);

const _staleAfter = Duration(seconds: 20);
const _pollInterval = Duration(seconds: 20);

class SymbolsListViewModel extends AsyncNotifier<List<SymbolModel>> {
  StreamSubscription<SymbolModel>? _liveSub;
  Timer? _pollTimer;
  String? _nextCursor;
  DateTime _lastLiveEventAt = DateTime.now();

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<SymbolModel>> build() async {
    // Wait for the Appwrite session (anonymous, at minimum) to be ready —
    // otherwise this races authViewModelProvider's session bootstrap and
    // fetchSymbols can hit the backend as an unauthenticated guest.
    await ref.watch(authViewModelProvider.future);

    final sort = ref.watch(symbolSortProvider);
    final repo = ref.watch(symbolsRepositoryProvider);

    ref.onDispose(() {
      _liveSub?.cancel();
      _pollTimer?.cancel();
    });

    unawaited(_liveSub?.cancel());
    _lastLiveEventAt = DateTime.now();
    _liveSub = repo.watchPriceUpdates().listen(_applyLiveUpdate);

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollIfStale());

    final result = await repo.fetchSymbols(sort: sort);
    return result.fold(
      (page) {
        _nextCursor = page.nextCursor;
        return page.items;
      },
      (failure) => throw failure,
    );
  }

  void _applyLiveUpdate(SymbolModel updated) {
    _lastLiveEventAt = DateTime.now();
    final current = state.valueOrNull;
    if (current == null) return;
    final index = current.indexWhere((s) => s.id == updated.id);
    if (index == -1) return;
    final next = List<SymbolModel>.from(current)..[index] = updated;
    state = AsyncData(next);
  }

  /// Realtime fallback: if no live event arrived recently, re-poll the
  /// first page and merge it in, per the "graceful reconnect and fallback
  /// to polling" requirement.
  Future<void> _pollIfStale() async {
    if (DateTime.now().difference(_lastLiveEventAt) < _staleAfter) return;
    final repo = ref.read(symbolsRepositoryProvider);
    final sort = ref.read(symbolSortProvider);
    final result = await repo.fetchSymbols(sort: sort);
    result.fold((page) {
      _nextCursor = page.nextCursor;
      state = AsyncData(page.items);
    }, (_) {});
  }

  Future<void> loadMore() async {
    final cursor = _nextCursor;
    final current = state.valueOrNull;
    if (cursor == null || current == null) return;

    final repo = ref.read(symbolsRepositoryProvider);
    final sort = ref.read(symbolSortProvider);
    final result = await repo.fetchSymbols(sort: sort, cursor: cursor);
    result.fold((page) {
      _nextCursor = page.nextCursor;
      state = AsyncData([...current, ...page.items]);
    }, (_) {});
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // The failure is already exposed through `state` as AsyncError.
    }
  }
}

final symbolsListViewModelProvider =
    AsyncNotifierProvider<SymbolsListViewModel, List<SymbolModel>>(SymbolsListViewModel.new);

/// The symbols list as shown on the symbols page: search, sort and the
/// favorites filter are applied locally on top of the fetched pages.
///
/// Search is local so it matches ticker, English and Persian names without
/// depending on a backend fulltext index, and so typing doesn't refetch and
/// re-subscribe to realtime on every keystroke. Sorting is re-applied
/// locally so order stays correct after live price updates and when the
/// list comes from the offline cache.
final visibleSymbolsProvider = Provider<AsyncValue<List<SymbolModel>>>((ref) {
  final symbolsAsync = ref.watch(symbolsListViewModelProvider);
  final query = ref.watch(symbolSearchQueryProvider).trim().toLowerCase();
  final sort = ref.watch(symbolSortProvider);
  final favoritesOnly = ref.watch(favoritesOnlyProvider);
  final watchlist = ref.watch(watchlistStreamProvider).valueOrNull ?? const <String>{};

  return symbolsAsync.whenData((items) {
    var visible = items.where((s) {
      if (favoritesOnly && !watchlist.contains(s.id)) return false;
      if (query.isEmpty) return true;
      return s.symbol.toLowerCase().contains(query) ||
          s.name.toLowerCase().contains(query) ||
          (s.nameFa?.contains(query) ?? false);
    }).toList();

    visible.sort(switch (sort) {
      SymbolSort.marketCap => (a, b) => b.marketCap.compareTo(a.marketCap),
      SymbolSort.gainers => (a, b) => b.change24h.compareTo(a.change24h),
      SymbolSort.losers => (a, b) => a.change24h.compareTo(b.change24h),
    });
    return visible;
  });
});
