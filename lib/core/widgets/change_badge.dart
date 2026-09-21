import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders a +/- percentage change with the correct arrow and color.
/// Deliberately built from a `Row` (not baked-in text) so Flutter's RTL
/// mirroring flips arrow position/direction for the `fa` locale for free.
class ChangeBadge extends StatelessWidget {
  const ChangeBadge({super.key, required this.percent, this.compact = false});

  final double percent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isGain = percent >= 0;
    final color = isGain ? AppColors.gain : AppColors.loss;
    final text = '${isGain ? '+' : ''}${percent.toStringAsFixed(2)}%';

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
