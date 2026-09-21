import 'package:flutter/foundation.dart';

@immutable
class SymbolEntity {
  const SymbolEntity({
    required this.id,
    required this.symbol,
    required this.name,
    this.nameFa,
    this.iconUrl,
    required this.price,
    required this.change24h,
    required this.change7d,
    required this.marketCap,
    required this.volume24h,
    required this.rank,
    required this.updatedAt,
    this.sparkline = const [],
  });

  final String id;
  final String symbol;
  final String name;
  final String? nameFa;
  final String? iconUrl;
  final double price;
  final double change24h;
  final double change7d;
  final double marketCap;
  final double volume24h;
  final int rank;
  final DateTime updatedAt;

  /// Optional recent-price series for the list row's mini sparkline. Not
  /// part of the required schema — populated when the backend's `symbols`
  /// document includes an optional `sparkline` attribute (see README).
  final List<double> sparkline;

  SymbolEntity copyWithLiveUpdate({double? price, double? change24h, double? change7d}) {
    return SymbolEntity(
      id: id,
      symbol: symbol,
      name: name,
      nameFa: nameFa,
      iconUrl: iconUrl,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      change7d: change7d ?? this.change7d,
      marketCap: marketCap,
      volume24h: volume24h,
      rank: rank,
      updatedAt: DateTime.now(),
      sparkline: sparkline,
    );
  }
}
