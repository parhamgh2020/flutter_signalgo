import '../../../../core/error/result.dart';
import '../entities/analysis_entity.dart';
import '../entities/candle_entity.dart';
import '../entities/timeframe.dart';

abstract class ChartRepository {
  Future<Result<List<CandleEntity>>> fetchCandles({
    required String symbol,
    required Timeframe timeframe,
    int limit = 200,
  });

  Future<Result<AnalysisEntity?>> fetchLatestAnalysis({
    required String symbol,
    required Timeframe timeframe,
  });

  /// Emits the latest (possibly still-forming) candle for [symbol]/[timeframe]
  /// as new ticks arrive via Realtime.
  Stream<CandleEntity> watchLiveCandle({required String symbol, required Timeframe timeframe});
}
