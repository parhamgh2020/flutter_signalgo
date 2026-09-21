import 'package:flutter/material.dart';

import '../../../../core/localization/localized_field.dart';
import '../../../../core/widgets/change_badge.dart';
import '../../../symbols/domain/entities/symbol_entity.dart';

class GainersLosersStrip extends StatelessWidget {
  const GainersLosersStrip({super.key, required this.title, required this.items});

  final String title;
  final List<SymbolEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final s = items[index];
              return Container(
                width: 110,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      context.localizedField(en: s.name, fa: s.nameFa),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    ChangeBadge(percent: s.change24h, compact: true),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
