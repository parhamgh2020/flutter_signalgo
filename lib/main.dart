import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/hive_provider.dart';
import 'core/providers/shared_preferences_provider.dart';

const _cacheBoxName = 'signalgo_cache';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await Hive.initFlutter();
  final cacheBox = await Hive.openBox<String>(_cacheBoxName);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        cacheBoxProvider.overrideWithValue(cacheBox),
      ],
      child: const SignalGoApp(),
    ),
  );
}
