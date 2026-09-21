import 'package:flutter/foundation.dart';

@immutable
class CandleEntity {
  const CandleEntity({
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
}
