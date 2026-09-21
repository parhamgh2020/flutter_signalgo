import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appwrite/appwrite_client.dart';
import '../../../../core/providers/repo_mode_provider.dart';
import '../../data/repositories/chart_repository_appwrite.dart';
import '../../data/repositories/chart_repository_mock.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/entities/candle_entity.dart';
import '../../domain/entities/timeframe.dart';
import '../../domain/repositories/chart_repository.dart';

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

class ChartCandlesController extends FamilyAsyncNotifier<List<CandleEntity>, ChartKey> {
  StreamSubscription<CandleEntity>? _liveSub;

  @override
  FutureOr<List<CandleEntity>> build(ChartKey arg) async {
    final repo = ref.watch(chartRepositoryProvider);

    ref.onDispose(() => _liveSub?.cancel());
    unawaited(_liveSub?.cancel());
    _liveSub = repo.watchLiveCandle(symbol: arg.symbol, timeframe: arg.timeframe).listen(_applyLive);

    final result = await repo.fetchCandles(symbol: arg.symbol, timeframe: arg.timeframe);
    return result.fold((v) => v, (f) => throw f);
  }

  void _applyLive(CandleEntity updated) {
    final current = state.valueOrNull;
    if (current == null || current.isEmpty) return;
    final next = List<CandleEntity>.from(current);
    if (next.last.timestamp == updated.timestamp) {
      next[next.length - 1] = updated;
    } else {
      next.add(updated);
    }
    state = AsyncData(next);
  }
}

final chartCandlesControllerProvider =
    AsyncNotifierProvider.family<ChartCandlesController, List<CandleEntity>, ChartKey>(
  ChartCandlesController.new,
);

final latestAnalysisProvider = FutureProvider.autoDispose.family<AnalysisEntity?, ChartKey>((ref, arg) async {
  final repo = ref.watch(chartRepositoryProvider);
  final result = await repo.fetchLatestAnalysis(symbol: arg.symbol, timeframe: arg.timeframe);
  return result.fold((v) => v, (f) => throw f);
});
