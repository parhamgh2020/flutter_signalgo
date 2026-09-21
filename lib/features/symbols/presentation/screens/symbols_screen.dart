import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../watchlist/presentation/providers/watchlist_providers.dart';
import '../../domain/repositories/symbols_repository.dart';
import '../providers/symbols_providers.dart';
import '../widgets/symbol_list_tile.dart';

class SymbolsScreen extends ConsumerStatefulWidget {
  const SymbolsScreen({super.key});

  @override
  ConsumerState<SymbolsScreen> createState() => _SymbolsScreenState();
}

class _SymbolsScreenState extends ConsumerState<SymbolsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(symbolsListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final symbolsAsync = ref.watch(symbolsListControllerProvider);
    final watchlist = ref.watch(watchlistStreamProvider).valueOrNull ?? const <String>{};
    final favoritesOnly = ref.watch(favoritesOnlyProvider);
    final sort = ref.watch(symbolSortProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.symbolsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) => ref.read(symbolSearchQueryProvider.notifier).state = value,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.sortMarketCap),
                  selected: sort == SymbolSort.marketCap,
                  onSelected: (_) => ref.read(symbolSortProvider.notifier).state = SymbolSort.marketCap,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.sortGainers),
                  selected: sort == SymbolSort.gainers,
                  onSelected: (_) => ref.read(symbolSortProvider.notifier).state = SymbolSort.gainers,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.sortLosers),
                  selected: sort == SymbolSort.losers,
                  onSelected: (_) => ref.read(symbolSortProvider.notifier).state = SymbolSort.losers,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.filterFavorites),
                  avatar: const Icon(Icons.star_rounded, size: 16),
                  selected: favoritesOnly,
                  onSelected: (v) => ref.read(favoritesOnlyProvider.notifier).state = v,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: symbolsAsync.when(
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (_, _) => const SkeletonListTile(),
              ),
              error: (error, _) => ErrorStateView(
                message: error is Failure ? error.localizedMessage(l10n) : l10n.errorGeneric,
                retryLabel: l10n.retry,
                onRetry: () => ref.read(symbolsListControllerProvider.notifier).refresh(),
              ),
              data: (items) {
                final visible = favoritesOnly ? items.where((s) => watchlist.contains(s.id)).toList() : items;
                if (visible.isEmpty) {
                  return EmptyState(
                    icon: favoritesOnly ? Icons.star_border_rounded : Icons.search_off_rounded,
                    title: favoritesOnly ? l10n.emptyWatchlist : l10n.emptySymbols,
                    subtitle: favoritesOnly ? l10n.emptyWatchlistHint : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(symbolsListControllerProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final item = visible[index];
                      final isWatched = watchlist.contains(item.id);
                      return SymbolListTile(
                        symbol: item,
                        isWatched: isWatched,
                        onTap: () {
                          ref.read(selectedSymbolProvider.notifier).state = item.id;
                          ref.read(selectedTabIndexProvider.notifier).state = 1;
                        },
                        onToggleWatch: () => ref
                            .read(watchlistControllerProvider.notifier)
                            .toggle(item.id, isCurrentlyWatched: isWatched),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
