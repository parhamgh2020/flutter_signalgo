import '../../domain/entities/analysis_entity.dart';

class AnalysisModel extends AnalysisEntity {
  const AnalysisModel({
    required super.symbol,
    required super.trend,
    required super.summaryEn,
    super.summaryFa,
    required super.supportLevels,
    required super.resistanceLevels,
    required super.indicators,
    required super.signal,
    required super.confidence,
    required super.createdAt,
  });

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
