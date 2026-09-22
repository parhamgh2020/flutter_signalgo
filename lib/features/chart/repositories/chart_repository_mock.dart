import 'dart:async';
import 'dart:math';

import '../../../core/error/result.dart';
import '../models/analysis_model.dart';
import '../models/candle_model.dart';
import '../models/timeframe.dart';
import 'chart_repository.dart';

class ChartRepositoryMock implements ChartRepository {
  final _seriesCache = <String, List<CandleModel>>{};

  String _key(String symbol, Timeframe tf) => '$symbol/${tf.apiValue}';

  List<CandleModel> _seriesFor(String symbol, Timeframe timeframe, {int count = 150}) {
    return _seriesCache.putIfAbsent(_key(symbol, timeframe), () {
      final rnd = Random(symbol.hashCode ^ timeframe.index);
      final span = timeframe.candleSpan;
      var price = 100 + rnd.nextDouble() * 60000;
      final now = DateTime.now();
      final candles = <CandleModel>[];
      for (var i = count - 1; i >= 0; i--) {
        final open = price;
        final drift = (rnd.nextDouble() - 0.48) * open * 0.02;
        final close = (open + drift).clamp(open * 0.9, open * 1.1).toDouble();
        final high = max(open, close) + rnd.nextDouble() * open * 0.006;
        final low = min(open, close) - rnd.nextDouble() * open * 0.006;
        candles.add(CandleModel(
          timestamp: now.subtract(span * i),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: rnd.nextDouble() * 1e6,
        ));
        price = close;
      }
      return candles;
    });
  }

  @override
  Future<Result<List<CandleModel>>> fetchCandles({
    required String symbol,
    required Timeframe timeframe,
    int limit = 200,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final series = _seriesFor(symbol, timeframe);
    return Ok(series.length <= limit ? series : series.sublist(series.length - limit));
  }

  @override
  Future<Result<AnalysisModel?>> fetchLatestAnalysis({
    required String symbol,
    required Timeframe timeframe,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final series = _seriesFor(symbol, timeframe);
    if (series.isEmpty) return const Ok(null);

    final recent = series.length > 20 ? series.sublist(series.length - 20) : series;
    final closes = recent.map((c) => c.close).toList();
    final ma = closes.reduce((a, b) => a + b) / closes.length;
    final slope = recent.last.close - recent.first.close;
    final trend = slope.abs() < recent.first.close * 0.005
        ? Trend.sideways
        : (slope > 0 ? Trend.bullish : Trend.bearish);

    final rnd = Random(symbol.hashCode ^ timeframe.index ^ series.length);
    final rsi = 30 + rnd.nextDouble() * 40 + (trend == Trend.bullish ? 10 : 0);
    final macd = slope / (recent.first.close == 0 ? 1 : recent.first.close) * 1000;

    final high = recent.map((c) => c.high).reduce(max);
    final low = recent.map((c) => c.low).reduce(min);

    final signal = switch (trend) {
      Trend.bullish => Signal.buy,
      Trend.bearish => Signal.sell,
      Trend.sideways => Signal.neutral,
    };

    return Ok(AnalysisModel(
      symbol: symbol,
      trend: trend,
      summaryEn: _summaryEn(symbol, trend, signal),
      summaryFa: _summaryFa(symbol, trend, signal),
      supportLevels: [low, low + (recent.last.close - low) * 0.4],
      resistanceLevels: [high, high - (high - recent.last.close) * 0.4],
      indicators: IndicatorValues(ma: ma, rsi: rsi.clamp(0, 100).toDouble(), macd: macd),
      signal: signal,
      confidence: 55 + rnd.nextDouble() * 35,
      createdAt: DateTime.now(),
    ));
  }

  String _summaryEn(String symbol, Trend trend, Signal signal) {
    final trendWord = switch (trend) {
      Trend.bullish => 'an uptrend',
      Trend.bearish => 'a downtrend',
      Trend.sideways => 'a sideways range',
    };
    return '$symbol is trading in $trendWord over the selected timeframe. '
        'Momentum and volume support a ${signal.name} bias for now — watch the nearest '
        'support/resistance band for confirmation.';
  }

  String _summaryFa(String symbol, Trend trend, Signal signal) {
    final trendWord = switch (trend) {
      Trend.bullish => 'روند صعودی',
      Trend.bearish => 'روند نزولی',
      Trend.sideways => 'روند خنثی',
    };
    final signalWord = switch (signal) {
      Signal.buy => 'خرید',
      Signal.sell => 'فروش',
      Signal.neutral => 'خنثی',
    };
    return '$symbol در این بازه زمانی در $trendWord قرار دارد. مومنتوم و حجم معاملات از سیگنال '
        '$signalWord پشتیبانی می‌کند — نزدیک‌ترین سطح حمایت یا مقاومت را برای تأیید زیر نظر بگیرید.';
  }

  @override
  Stream<CandleModel> watchLiveCandle({required String symbol, required Timeframe timeframe}) async* {
    final rnd = Random();
    while (true) {
      await Future.delayed(const Duration(seconds: 4));
      final series = _seriesFor(symbol, timeframe);
      final last = series.last;
      final drift = (rnd.nextDouble() - 0.5) * last.close * 0.004;
      final close = last.close + drift;
      final updated = CandleModel(
        timestamp: last.timestamp,
        open: last.open,
        high: max(last.high, close),
        low: min(last.low, close),
        close: close,
        volume: last.volume + rnd.nextDouble() * 1e4,
      );
      series[series.length - 1] = updated;
      yield updated;
    }
  }
}
