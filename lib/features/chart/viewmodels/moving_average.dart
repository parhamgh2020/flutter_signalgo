import '../models/candle_model.dart';

/// Simple moving average of closes over [window] candles, aligned 1:1 with
/// [candles] (null where there isn't yet a full window). Computed client-side
/// from OHLC data — the backend's `analyses.indicators.ma` is a single
/// latest-value snapshot, not a series, so it can't drive a chart overlay.
List<double?> simpleMovingAverage(List<CandleModel> candles, int window) {
  final result = List<double?>.filled(candles.length, null);
  double sum = 0;
  for (var i = 0; i < candles.length; i++) {
    sum += candles[i].close;
    if (i >= window) sum -= candles[i - window].close;
    if (i >= window - 1) result[i] = sum / window;
  }
  return result;
}
