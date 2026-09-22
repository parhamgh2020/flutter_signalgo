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
class AnalysisModel {
  const AnalysisModel({
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

  factory AnalysisModel.fromMap(Map<String, dynamic> map) {
    final indicatorsRaw = map['indicators'];
    final indicatorsMap = indicatorsRaw is Map
        ? indicatorsRaw
        : (indicatorsRaw is String && indicatorsRaw.isNotEmpty ? _tryDecode(indicatorsRaw) : const {});

    return AnalysisModel(
      symbol: map['symbol'] as String,
      trend: _trendFromString(map['trend'] as String?),
      summaryEn: map['summary_en'] as String? ?? '',
      summaryFa: map['summary_fa'] as String?,
      supportLevels: _doubleList(map['support_levels']),
      resistanceLevels: _doubleList(map['resistance_levels']),
      indicators: IndicatorValues(
        ma: (indicatorsMap['ma'] as num?)?.toDouble(),
        rsi: (indicatorsMap['rsi'] as num?)?.toDouble(),
        macd: (indicatorsMap['macd'] as num?)?.toDouble(),
      ),
      signal: _signalFromString(map['signal'] as String?),
      confidence: (map['confidence'] as num? ?? 0).toDouble(),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static Map _tryDecode(String raw) {
    try {
      return Uri.splitQueryString(raw);
    } catch (_) {
      return const {};
    }
  }

  static List<double> _doubleList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => (e as num).toDouble()).toList();
  }

  static Trend _trendFromString(String? value) => switch (value) {
        'bullish' => Trend.bullish,
        'bearish' => Trend.bearish,
        _ => Trend.sideways,
      };

  static Signal _signalFromString(String? value) => switch (value) {
        'buy' => Signal.buy,
        'sell' => Signal.sell,
        _ => Signal.neutral,
      };
}
