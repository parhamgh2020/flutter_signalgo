import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/timeframe.dart';
import '../../domain/logic/moving_average.dart';
import '../providers/chart_providers.dart';
import '../widgets/analysis_card.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/symbol_switcher.dart';
import '../widgets/timeframe_selector.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedSymbol = ref.watch(selectedSymbolProvider);
    final timeframe = ref.watch(selectedTimeframeProvider);
    final showMA = ref.watch(showMAProvider);
    final showRSI = ref.watch(showRSIProvider);
    final showMACD = ref.watch(showMACDProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chartTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SymbolSwitcher(
                selectedId: selectedSymbol,
                onChanged: (id) => ref.read(selectedSymbolProvider.notifier).state = id,
              ),
              const SizedBox(height: 8),
              if (selectedSymbol == null)
                Expanded(
                  child: EmptyState(icon: Icons.candlestick_chart_outlined, title: l10n.chooseCoinFirst),
                )
              else
                Expanded(
                  child: _ChartBody(symbolId: selectedSymbol, timeframe: timeframe),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TimeframeSelector(value: timeframe, onChanged: (tf) => ref.read(selectedTimeframeProvider.notifier).state = tf)),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.indicatorMA),
                      selected: showMA,
                      onSelected: (v) => ref.read(showMAProvider.notifier).state = v,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.indicatorRSI),
                      selected: showRSI,
                      onSelected: (v) => ref.read(showRSIProvider.notifier).state = v,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.indicatorMACD),
                      selected: showMACD,
                      onSelected: (v) => ref.read(showMACDProvider.notifier).state = v,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartBody extends ConsumerWidget {
  const _ChartBody({required this.symbolId, required this.timeframe});

  final String symbolId;
  final Timeframe timeframe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (symbol: symbolId, timeframe: timeframe);
    final candlesAsync = ref.watch(chartCandlesControllerProvider(key));
    final analysisAsync = ref.watch(latestAnalysisProvider(key));
    final showMA = ref.watch(showMAProvider);
    final showRSI = ref.watch(showRSIProvider);
    final showMACD = ref.watch(showMACDProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 280,
            child: candlesAsync.when(
              loading: () => const Skeleton(height: 280, borderRadius: 16),
              error: (error, _) => ErrorStateView(
                message: error is Failure ? error.localizedMessage(l10n) : l10n.errorGeneric,
                retryLabel: l10n.retry,
                onRetry: () => ref.invalidate(chartCandlesControllerProvider(key)),
              ),
              data: (candles) {
                if (candles.isEmpty) {
                  return EmptyState(icon: Icons.show_chart, title: l10n.noAnalysisAvailable);
                }
                final ma = simpleMovingAverage(candles, 20);
                return CandlestickChart(candles: candles, maSeries: ma, showMA: showMA);
              },
            ),
          ),
          const SizedBox(height: 16),
          analysisAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => ErrorStateView(
              message: error is Failure ? error.localizedMessage(l10n) : l10n.errorGeneric,
              retryLabel: l10n.retry,
              onRetry: () => ref.invalidate(latestAnalysisProvider(key)),
            ),
            data: (analysis) {
              if (analysis == null) {
                return EmptyState(icon: Icons.insights_outlined, title: l10n.noAnalysisAvailable);
              }
              return AnalysisCard(analysis: analysis, showRSI: showRSI, showMACD: showMACD);
            },
          ),
        ],
      ),
    );
  }
}
