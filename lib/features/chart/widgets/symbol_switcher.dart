import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../symbols/viewmodels/symbols_view_model.dart';

class SymbolSwitcher extends ConsumerWidget {
  const SymbolSwitcher({super.key, required this.selectedId, required this.onChanged});

  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbolsAsync = ref.watch(symbolsListViewModelProvider);
    final l10n = AppLocalizations.of(context);

    return symbolsAsync.when(
      loading: () => const SizedBox(height: 40),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(l10n.selectSymbol),
            value: selectedId != null && items.any((s) => s.id == selectedId) ? selectedId : null,
            items: [
              for (final s in items) DropdownMenuItem(value: s.id, child: Text('${s.symbol} · ${s.name}')),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        );
      },
    );
  }
}
