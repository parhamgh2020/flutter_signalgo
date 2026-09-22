import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../viewmodels/news_view_model.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/gainers_losers_strip.dart';
import '../widgets/market_summary_header.dart';
import '../widgets/news_list_item.dart';
import 'news_detail_view.dart';

const _tags = ['bitcoin', 'ethereum', 'solana', 'defi', 'markets', 'regulation', 'on-chain'];

class NewsView extends ConsumerStatefulWidget {
  const NewsView({super.key});

  @override
  ConsumerState<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends ConsumerState<NewsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
        ref.read(newsListViewModelProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overviewAsync = ref.watch(marketOverviewProvider);
    final featuredAsync = ref.watch(featuredNewsProvider);
    final newsAsync = ref.watch(newsListViewModelProvider);
    final selectedTag = ref.watch(selectedNewsTagProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(marketOverviewProvider);
          ref.invalidate(featuredNewsProvider);
          await ref.read(newsListViewModelProvider.notifier).refresh();
        },
        child: ListView(
          controller: _scrollController,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: overviewAsync.when(
                loading: () => const Skeleton(height: 92, borderRadius: 16),
                error: (_, _) => const SizedBox.shrink(),
                data: (overview) => MarketSummaryHeader(overview: overview),
              ),
            ),
            const SizedBox(height: 16),
            overviewAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (overview) => Column(
                children: [
                  GainersLosersStrip(title: l10n.topGainers, items: overview.topGainers),
                  const SizedBox(height: 12),
                  GainersLosersStrip(title: l10n.topLosers, items: overview.topLosers),
                ],
              ),
            ),
            const SizedBox(height: 16),
            featuredAsync.when(
              loading: () => const Skeleton(height: 160, borderRadius: 16),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) => FeaturedCarousel(
                items: items,
                onTap: (article) => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NewsDetailView(article: article)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l10n.allTags),
                      selected: selectedTag == null,
                      onSelected: (_) => ref.read(selectedNewsTagProvider.notifier).state = null,
                    ),
                  ),
                  for (final tag in _tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tag),
                        selected: selectedTag == tag,
                        onSelected: (_) => ref.read(selectedNewsTagProvider.notifier).state = tag,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            newsAsync.when(
              loading: () => Column(children: List.generate(4, (_) => const SkeletonListTile())),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorStateView(
                  message: error is Failure ? error.localizedMessage(l10n) : l10n.errorGeneric,
                  retryLabel: l10n.retry,
                  onRetry: () => ref.read(newsListViewModelProvider.notifier).refresh(),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(icon: Icons.newspaper_outlined, title: l10n.emptyNews);
                }
                return Column(
                  children: [
                    for (final article in items)
                      NewsListItem(
                        article: article,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => NewsDetailView(article: article)),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
