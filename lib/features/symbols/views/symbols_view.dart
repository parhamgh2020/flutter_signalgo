import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/navigation_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../watchlist/viewmodels/watchlist_view_model.dart';
import '../repositories/symbols_repository.dart';
import '../viewmodels/symbols_view_model.dart';
import '../widgets/symbol_list_tile.dart';

class SymbolsView extends ConsumerStatefulWidget {
  const SymbolsView({super.key});

  @override
  ConsumerState<SymbolsView> createState() => _SymbolsViewState();
}

class _SymbolsViewState extends ConsumerState<SymbolsView> {
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
      ref.read(symbolsListViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final symbolsAsync = ref.watch(visibleSymbolsProvider);
    final isSearching = ref.watch(symbolSearchQueryProvider).trim().isNotEmpty;
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
                onRetry: () => ref.read(symbolsListViewModelProvider.notifier).refresh(),
              ),
              data: (visible) {
                if (visible.isEmpty) {
                  final showWatchlistHint = favoritesOnly && !isSearching;
                  return EmptyState(
                    icon: showWatchlistHint ? Icons.star_border_rounded : Icons.search_off_rounded,
                    title: showWatchlistHint ? l10n.emptyWatchlist : l10n.emptySymbols,
                    subtitle: showWatchlistHint ? l10n.emptyWatchlistHint : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(symbolsListViewModelProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    // Keep pull-to-refresh working when the list is shorter
                    // than the screen.
                    physics: const AlwaysScrollableScrollPhysics(),
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
                            .read(watchlistViewModelProvider.notifier)
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
