import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/timeframe.dart';

class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({super.key, required this.value, required this.onChanged});

  final Timeframe value;
  final ValueChanged<Timeframe> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      Timeframe.h1: l10n.timeframe1h,
      Timeframe.h4: l10n.timeframe4h,
      Timeframe.d1: l10n.timeframe1d,
      Timeframe.w1: l10n.timeframe1w,
    };
    return SegmentedButton<Timeframe>(
      segments: [
        for (final tf in Timeframe.values) ButtonSegment(value: tf, label: Text(labels[tf]!)),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
