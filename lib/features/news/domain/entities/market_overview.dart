import 'package:flutter/foundation.dart';

import '../../../symbols/domain/entities/symbol_entity.dart';

/// Backend schema has no dedicated market-overview collection, so this is
/// computed client-side from the top symbols by market cap (see
/// `marketOverviewProvider`) — an approximation, not an exhaustive sum
/// across every listed asset. Fear & Greed has no backing field either;
/// it's derived heuristically from aggregate 24h momentum.
@immutable
class MarketOverview {
  const MarketOverview({
    required this.totalMarketCap,
    required this.totalVolume24h,
    required this.btcDominance,
    required this.fearGreedIndex,
    required this.topGainers,
    required this.topLosers,
  });

  final double totalMarketCap;
  final double totalVolume24h;

  /// 0–100.
  final double btcDominance;

  /// 0 (extreme fear) – 100 (extreme greed).
  final int fearGreedIndex;

  final List<SymbolEntity> topGainers;
  final List<SymbolEntity> topLosers;
}
