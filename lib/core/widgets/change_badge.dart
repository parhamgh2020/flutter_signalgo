import 'package:flutter/material.dart';

import '../localization/persian_numbers.dart';
import '../theme/app_colors.dart';

/// Renders a +/- percentage change with the correct arrow and color.
/// Deliberately built from a `Row` (not baked-in text) so Flutter's RTL
/// mirroring flips arrow position/direction for the `fa` locale for free.
class ChangeBadge extends StatelessWidget {
  const ChangeBadge({super.key, required this.percent, this.compact = false, this.persianDigits = false});

  final double percent;
  final bool compact;
  final bool persianDigits;

  @override
  Widget build(BuildContext context) {
    // Classify on the displayed (rounded) value so e.g. -0.001 renders as
    // "+0.00%" in gain color instead of a red "-0.00%".
    final rounded = double.parse(percent.toStringAsFixed(2));
    final isGain = rounded >= 0;
    final color = isGain ? AppColors.gain : AppColors.loss;
    var text = '${isGain ? '+' : ''}${rounded.abs() == 0 ? '0.00' : rounded.toStringAsFixed(2)}%';
    if (persianDigits) text = toPersianDigits(text);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isGain ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: color,
          size: compact ? 16 : 20,
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: compact ? 12 : 14,
          ),
        ),
      ],
    );
  }
}
