import '../../domain/entities/symbol_entity.dart';

class SymbolModel extends SymbolEntity {
  const SymbolModel({
    required super.id,
    required super.symbol,
    required super.name,
    super.nameFa,
    super.iconUrl,
    required super.price,
    required super.change24h,
    required super.change7d,
    required super.marketCap,
    required super.volume24h,
    required super.rank,
    required super.updatedAt,
    super.sparkline,
  });

  factory SymbolModel.fromMap(Map<String, dynamic> map) {
    return SymbolModel(
      id: map[r'$id'] as String? ?? map['id'] as String,
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      nameFa: map['name_fa'] as String?,
      iconUrl: map['icon_url'] as String?,
      price: (map['price'] as num).toDouble(),
      change24h: (map['change_24h'] as num).toDouble(),
      change7d: (map['change_7d'] as num).toDouble(),
      marketCap: (map['market_cap'] as num).toDouble(),
      volume24h: (map['volume_24h'] as num).toDouble(),
      rank: (map['rank'] as num).toInt(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
      sparkline: (map['sparkline'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? const [],
    );
  }

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
