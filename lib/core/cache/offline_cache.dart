import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Thin JSON read/write wrapper around a single Hive `Box<String>`, used by
/// repositories to persist the last-fetched page of data for offline
/// fallback. Not a general cache — just "last known good" per key.
class OfflineCache {
  const OfflineCache(this._box);

  final Box<String> _box;

  Future<void> writeList(String key, List<Map<String, dynamic>> items) {
    return _box.put(key, jsonEncode(items));
  }

  List<Map<String, dynamic>>? readList(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) {
    return _box.put(key, jsonEncode(value));
  }

  Map<String, dynamic>? readMap(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
