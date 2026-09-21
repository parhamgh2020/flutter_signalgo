import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localized_field.dart';
import '../../../../core/localization/persian_numbers.dart';
import '../../../../core/settings/app_currency.dart';
import '../../../../core/widgets/change_badge.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/symbol_entity.dart';
import 'mini_sparkline.dart';

class SymbolListTile extends ConsumerWidget {
  const SymbolListTile({
    super.key,
    required this.symbol,
    required this.isWatched,
    required this.onTap,
    required this.onToggleWatch,
  });

  final SymbolEntity symbol;
  final bool isWatched;
  final VoidCallback onTap;
  final VoidCallback onToggleWatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(displayCurrencyControllerProvider);
    final persianDigits = ref.watch(persianDigitsControllerProvider);
    final name = context.localizedField(en: symbol.name, fa: symbol.nameFa);

    var priceText = currency.format(symbol.price, persianDigits: persianDigits);
    if (persianDigits) priceText = toPersianDigits(priceText);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        child: Text(symbol.symbol.substring(0, 1)),
      ),
      title: Text(symbol.symbol, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniSparkline(values: symbol.sparkline),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(priceText, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              ChangeBadge(percent: symbol.change24h, compact: true),
            ],
          ),
          IconButton(
            icon: Icon(isWatched ? Icons.star_rounded : Icons.star_border_rounded),
            color: isWatched ? Colors.amber : null,
            onPressed: onToggleWatch,
          ),
        ],
      ),
    );
  }
}
