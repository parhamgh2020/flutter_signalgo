import '../../domain/entities/candle_entity.dart';

class CandleModel extends CandleEntity {
  const CandleModel({
    required super.timestamp,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
  });

  factory CandleModel.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'];
    return CandleModel(
      timestamp: ts is String ? DateTime.parse(ts) : DateTime.fromMillisecondsSinceEpoch((ts as num).toInt()),
      open: (map['open'] as num).toDouble(),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
      volume: (map['volume'] as num? ?? 0).toDouble(),
    );
  }
}
