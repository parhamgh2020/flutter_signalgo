import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/cache/offline_cache.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/viewmodels/auth_view_model.dart';
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
    final search = ref.watch(symbolSearchQueryProvider);
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

    final result = await repo.fetchSymbols(sort: sort, search: search.isEmpty ? null : search);
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
    final search = ref.read(symbolSearchQueryProvider);
    final result = await repo.fetchSymbols(sort: sort, search: search.isEmpty ? null : search);
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
    final search = ref.read(symbolSearchQueryProvider);
    final result = await repo.fetchSymbols(
      sort: sort,
      search: search.isEmpty ? null : search,
      cursor: cursor,
    );
    result.fold((page) {
      _nextCursor = page.nextCursor;
      state = AsyncData([...current, ...page.items]);
    }, (_) {});
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final symbolsListViewModelProvider =
    AsyncNotifierProvider<SymbolsListViewModel, List<SymbolModel>>(SymbolsListViewModel.new);
