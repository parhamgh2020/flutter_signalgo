import 'package:flutter/foundation.dart';

enum Trend { bullish, bearish, sideways }

enum Signal { buy, sell, neutral }

@immutable
class IndicatorValues {
  const IndicatorValues({this.ma, this.rsi, this.macd});

  final double? ma;
  final double? rsi;
  final double? macd;
}

@immutable
class AnalysisEntity {
  const AnalysisEntity({
    required this.symbol,
    required this.trend,
    required this.summaryEn,
    this.summaryFa,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.indicators,
    required this.signal,
    required this.confidence,
    required this.createdAt,
  });

  final String symbol;
  final Trend trend;
  final String summaryEn;
  final String? summaryFa;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final IndicatorValues indicators;
  final Signal signal;

  /// 0–100.
  final double confidence;
  final DateTime createdAt;
}
