import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/providers/repo_mode_provider.dart';
import '../repositories/watchlist_repository.dart';
import '../repositories/watchlist_repository_appwrite.dart';
import '../repositories/watchlist_repository_mock.dart';

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) {
    return WatchlistRepositoryMock();
  }
  return WatchlistRepositoryAppwrite(
    databases: ref.watch(appwriteDatabasesProvider),
    account: ref.watch(appwriteAccountProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    config: ref.watch(appwriteConfigProvider),
  );
});

final watchlistStreamProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(watchlistRepositoryProvider).watch();
});

class WatchlistViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggle(String symbolId, {required bool isCurrentlyWatched}) async {
    final repo = ref.read(watchlistRepositoryProvider);
    state = const AsyncLoading();
    final result = isCurrentlyWatched ? await repo.remove(symbolId) : await repo.add(symbolId);
    state = result.fold((_) => const AsyncData(null), (f) => AsyncError(f, StackTrace.current));
  }
}

final watchlistViewModelProvider =
    NotifierProvider<WatchlistViewModel, AsyncValue<void>>(WatchlistViewModel.new);
