import '../../../core/error/result.dart';
import '../models/analysis_model.dart';
import '../models/candle_model.dart';
import '../models/timeframe.dart';

abstract class ChartRepository {
  Future<Result<List<CandleModel>>> fetchCandles({
    required String symbol,
    required Timeframe timeframe,
    int limit = 200,
  });

  Future<Result<AnalysisModel?>> fetchLatestAnalysis({
    required String symbol,
    required Timeframe timeframe,
  });

  /// Emits the latest (possibly still-forming) candle for [symbol]/[timeframe]
  /// as new ticks arrive via Realtime.
  Stream<CandleModel> watchLiveCandle({required String symbol, required Timeframe timeframe});
}
