import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/market_overview.dart';

class MarketSummaryHeader extends StatelessWidget {
  const MarketSummaryHeader({super.key, required this.overview});

  final MarketOverview overview;

  String _compact(double value) {
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    return '\$${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            _Stat(label: l10n.marketCapLabel, value: _compact(overview.totalMarketCap)),
            _Stat(label: l10n.volume24hLabel, value: _compact(overview.totalVolume24h)),
            _Stat(label: l10n.btcDominance, value: '${overview.btcDominance.toStringAsFixed(1)}%'),
            _Stat(label: l10n.fearGreedIndex, value: '${overview.fearGreedIndex}'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
