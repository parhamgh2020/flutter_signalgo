import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the active bottom-nav tab (Symbols / Chart / News / Settings).
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// The symbol the Chart & Analysis tab is currently showing. Set from the
/// Symbols tab (tap a coin) or the chart's own symbol switcher; both write
/// here so the two stay in sync without tab-specific plumbing.
final selectedSymbolProvider = StateProvider<String?>((ref) => null);
