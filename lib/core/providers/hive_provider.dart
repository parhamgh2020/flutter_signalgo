import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Single JSON-string cache box for offline reads (last-fetched symbols,
/// news, market overview). Opened in `main.dart` before `runApp` and
/// provided here via override — no per-feature typed Hive adapters needed
/// since values are stored as JSON strings and decoded by callers.
final cacheBoxProvider = Provider<Box<String>>((ref) {
  throw UnimplementedError('cacheBoxProvider must be overridden in main()');
});
