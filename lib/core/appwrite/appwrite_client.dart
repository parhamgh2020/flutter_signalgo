import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appwrite_config.dart';

final appwriteConfigProvider = Provider<AppwriteConfig>((ref) {
  return AppwriteConfig.fromEnvironment();
});

/// Centralized Appwrite client setup. Every repository pulls its
/// service (Databases/Account/Realtime) from this one configured [Client]
/// instead of constructing its own.
final appwriteClientProvider = Provider<Client>((ref) {
  final config = ref.watch(appwriteConfigProvider);

  final client = Client()
      .setEndpoint(config.endpoint)
      .setProject(config.projectId);

  if (!kIsWeb && config.selfSigned) {
    client.setSelfSigned(status: true);
  }

  return client;
});

final appwriteAccountProvider = Provider<Account>((ref) {
  return Account(ref.watch(appwriteClientProvider));
});

final appwriteDatabasesProvider = Provider<Databases>((ref) {
  return Databases(ref.watch(appwriteClientProvider));
});

final appwriteRealtimeProvider = Provider<Realtime>((ref) {
  return Realtime(ref.watch(appwriteClientProvider));
});
