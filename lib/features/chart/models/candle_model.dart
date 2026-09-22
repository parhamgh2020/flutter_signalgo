import 'package:flutter/foundation.dart';

@immutable
class CandleModel {
  const CandleModel({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get isBullish => close >= open;

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
