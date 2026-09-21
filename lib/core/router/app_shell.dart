import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chart/presentation/screens/chart_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/symbols/presentation/screens/symbols_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/navigation_providers.dart';
import '../widgets/offline_banner.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabIndexProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: index,
              children: const [
                SymbolsScreen(),
                ChartScreen(),
                NewsScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(selectedTabIndexProvider.notifier).state = i,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.list_alt_rounded), label: l10n.navSymbols),
          NavigationDestination(icon: const Icon(Icons.candlestick_chart_rounded), label: l10n.navChart),
          NavigationDestination(icon: const Icon(Icons.newspaper_rounded), label: l10n.navNews),
          NavigationDestination(icon: const Icon(Icons.settings_rounded), label: l10n.navSettings),
        ],
      ),
    );
  }
}
