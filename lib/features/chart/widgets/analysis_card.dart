import 'package:flutter/material.dart';

import '../../../core/localization/localized_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/analysis_model.dart';

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key, required this.analysis, required this.showRSI, required this.showMACD});

  final AnalysisModel analysis;
  final bool showRSI;
  final bool showMACD;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = context.localizedField(en: analysis.summaryEn, fa: analysis.summaryFa);

    final signalColor = switch (analysis.signal) {
      Signal.buy => AppColors.gain,
      Signal.sell => AppColors.loss,
      Signal.neutral => AppColors.neutral,
    };
    final signalLabel = switch (analysis.signal) {
      Signal.buy => l10n.signalBuy,
      Signal.sell => l10n.signalSell,
      Signal.neutral => l10n.signalNeutral,
    };
    final trendLabel = switch (analysis.trend) {
      Trend.bullish => l10n.trendBullish,
      Trend.bearish => l10n.trendBearish,
      Trend.sideways => l10n.trendSideways,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(trendLabel),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(signalLabel),
                  backgroundColor: signalColor.withValues(alpha: 0.18),
                  labelStyle: TextStyle(color: signalColor, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  l10n.confidenceLabel(analysis.confidence.round()),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(summary, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LevelsChip(
                  label: l10n.supportLevels,
                  values: analysis.supportLevels,
                  color: AppColors.gain,
                ),
                _LevelsChip(
                  label: l10n.resistanceLevels,
                  values: analysis.resistanceLevels,
                  color: AppColors.loss,
                ),
                if (showRSI && analysis.indicators.rsi != null)
                  _StatChip(label: l10n.indicatorRSI, value: analysis.indicators.rsi!.toStringAsFixed(1)),
                if (showMACD && analysis.indicators.macd != null)
                  _StatChip(label: l10n.indicatorMACD, value: analysis.indicators.macd!.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelsChip extends StatelessWidget {
  const _LevelsChip({required this.label, required this.values, required this.color});

  final String label;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final text = values.map((v) => v.toStringAsFixed(v >= 100 ? 0 : 2)).join(' / ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label: $text', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label $value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
