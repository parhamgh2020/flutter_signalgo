import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appwrite/appwrite_client.dart';
import '../../../core/providers/repo_mode_provider.dart';
import '../models/analysis_model.dart';
import '../models/candle_model.dart';
import '../models/timeframe.dart';
import '../repositories/chart_repository.dart';
import '../repositories/chart_repository_appwrite.dart';
import '../repositories/chart_repository_mock.dart';
import 'moving_average.dart';

typedef ChartKey = ({String symbol, Timeframe timeframe});

final chartRepositoryProvider = Provider<ChartRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) {
    return ChartRepositoryMock();
  }
  return ChartRepositoryAppwrite(
    databases: ref.watch(appwriteDatabasesProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    config: ref.watch(appwriteConfigProvider),
  );
});

final selectedTimeframeProvider = StateProvider<Timeframe>((ref) => Timeframe.d1);

final showMAProvider = StateProvider<bool>((ref) => true);
final showRSIProvider = StateProvider<bool>((ref) => false);
final showMACDProvider = StateProvider<bool>((ref) => false);

class ChartCandlesViewModel extends FamilyAsyncNotifier<List<CandleModel>, ChartKey> {
  StreamSubscription<CandleModel>? _liveSub;

  @override
  FutureOr<List<CandleModel>> build(ChartKey arg) async {
    final repo = ref.watch(chartRepositoryProvider);

    ref.onDispose(() => _liveSub?.cancel());
    unawaited(_liveSub?.cancel());
    _liveSub = repo.watchLiveCandle(symbol: arg.symbol, timeframe: arg.timeframe).listen(_applyLive);

    final result = await repo.fetchCandles(symbol: arg.symbol, timeframe: arg.timeframe);
    return result.fold((v) => v, (f) => throw f);
  }

  void _applyLive(CandleModel updated) {
    final current = state.valueOrNull;
    if (current == null || current.isEmpty) return;
    final next = List<CandleModel>.from(current);
    if (next.last.timestamp == updated.timestamp) {
      next[next.length - 1] = updated;
    } else {
      next.add(updated);
    }
    state = AsyncData(next);
  }
}

final chartCandlesViewModelProvider =
    AsyncNotifierProvider.family<ChartCandlesViewModel, List<CandleModel>, ChartKey>(
  ChartCandlesViewModel.new,
);

final latestAnalysisProvider = FutureProvider.autoDispose.family<AnalysisModel?, ChartKey>((ref, arg) async {
  final repo = ref.watch(chartRepositoryProvider);
  final result = await repo.fetchLatestAnalysis(symbol: arg.symbol, timeframe: arg.timeframe);
  return result.fold((v) => v, (f) => throw f);
});

/// Derived presentation state: the MA overlay series for the current candle
/// data. Kept here (not computed in the View) so the View stays display-only.
final chartMovingAverageProvider = Provider.family<List<double?>, ChartKey>((ref, key) {
  final candles = ref.watch(chartCandlesViewModelProvider(key)).valueOrNull;
  if (candles == null) return const [];
  return simpleMovingAverage(candles, 20);
});
