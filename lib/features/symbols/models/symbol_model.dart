import 'package:flutter/foundation.dart';

@immutable
class SymbolModel {
  const SymbolModel({
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

  SymbolModel copyWithLiveUpdate({double? price, double? change24h, double? change7d}) {
    return SymbolModel(
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

  factory SymbolModel.fromMap(Map<String, dynamic> map) {
    return SymbolModel(
      id: map[r'$id'] as String? ?? map['id'] as String,
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      nameFa: map['name_fa'] as String?,
      iconUrl: map['icon_url'] as String?,
      price: _toDouble(map['price']),
      change24h: _toDouble(map['change_24h']),
      change7d: _toDouble(map['change_7d']),
      marketCap: _toDouble(map['market_cap']),
      volume24h: _toDouble(map['volume_24h']),
      rank: _toDouble(map['rank']).toInt(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
      sparkline: (map['sparkline'] as List<dynamic>?)?.map(_toDouble).toList() ?? const [],
    );
  }

  /// Lenient numeric parsing: backend rows may have null or string-typed
  /// numeric attributes, which shouldn't break the whole list.
  static double _toDouble(Object? value) => switch (value) {
        num v => v.toDouble(),
        String v => double.tryParse(v) ?? 0,
        _ => 0,
      };

  Map<String, dynamic> toCacheMap() {
    return {
      r'$id': id,
      'symbol': symbol,
      'name': name,
      'name_fa': nameFa,
      'icon_url': iconUrl,
      'price': price,
      'change_24h': change24h,
      'change_7d': change7d,
      'market_cap': marketCap,
      'volume_24h': volume24h,
      'rank': rank,
      'updated_at': updatedAt.toIso8601String(),
      'sparkline': sparkline,
    };
  }
}
