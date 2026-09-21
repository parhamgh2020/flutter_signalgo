import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appwrite/appwrite_client.dart';
import '../../../../core/cache/offline_cache.dart';
import '../../../../core/providers/hive_provider.dart';
import '../../../../core/providers/repo_mode_provider.dart';
import '../../../symbols/presentation/providers/symbols_providers.dart';
import '../../data/repositories/news_repository_appwrite.dart';
import '../../data/repositories/news_repository_mock.dart';
import '../../domain/entities/market_overview.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) {
    return NewsRepositoryMock();
  }
  return NewsRepositoryAppwrite(
    databases: ref.watch(appwriteDatabasesProvider),
    config: ref.watch(appwriteConfigProvider),
    cache: OfflineCache(ref.watch(cacheBoxProvider)),
  );
});

final selectedNewsTagProvider = StateProvider<String?>((ref) => null);
final newsSearchQueryProvider = StateProvider<String>((ref) => '');

final featuredNewsProvider = FutureProvider.autoDispose<List<NewsEntity>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  final result = await repo.fetchFeatured();
  return result.fold((v) => v, (f) => throw f);
});

final marketOverviewProvider = FutureProvider.autoDispose<MarketOverview>((ref) async {
  final repo = ref.watch(symbolsRepositoryProvider);
  final result = await repo.fetchSymbols(limit: 100);
  return result.fold((page) {
    final items = page.items;
    final totalMarketCap = items.fold<double>(0, (sum, s) => sum + s.marketCap);
    final totalVolume = items.fold<double>(0, (sum, s) => sum + s.volume24h);
    final btc = items.where((s) => s.symbol == 'BTC').fold<double>(0, (sum, s) => sum + s.marketCap);
    final dominance = totalMarketCap == 0 ? 0.0 : (btc / totalMarketCap) * 100;

    final avgChange = items.isEmpty
        ? 0.0
        : items.fold<double>(0, (sum, s) => sum + s.change24h) / items.length;
    final fearGreed = (50 + avgChange * 4).clamp(0, 100).round();

    final sortedByChange = [...items]..sort((a, b) => b.change24h.compareTo(a.change24h));

    return MarketOverview(
      totalMarketCap: totalMarketCap,
      totalVolume24h: totalVolume,
      btcDominance: dominance,
      fearGreedIndex: fearGreed,
      topGainers: sortedByChange.take(5).toList(),
      topLosers: sortedByChange.reversed.take(5).toList(),
    );
  }, (f) => throw f);
});

class NewsListController extends AsyncNotifier<List<NewsEntity>> {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<NewsEntity>> build() async {
    final tag = ref.watch(selectedNewsTagProvider);
    final search = ref.watch(newsSearchQueryProvider);
    final repo = ref.watch(newsRepositoryProvider);

    final result = await repo.fetchNews(tag: tag, search: search.isEmpty ? null : search);
    return result.fold((page) {
      _nextCursor = page.nextCursor;
      return page.items;
    }, (f) => throw f);
  }

  Future<void> loadMore() async {
    final cursor = _nextCursor;
    final current = state.valueOrNull;
    if (cursor == null || current == null) return;

    final repo = ref.read(newsRepositoryProvider);
    final tag = ref.read(selectedNewsTagProvider);
    final search = ref.read(newsSearchQueryProvider);
    final result = await repo.fetchNews(
      tag: tag,
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

final newsListControllerProvider =
    AsyncNotifierProvider<NewsListController, List<NewsEntity>>(NewsListController.new);
