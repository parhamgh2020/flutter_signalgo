import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When true, every feature wires its mock repository instead of the
/// Appwrite-backed one, so the UI is fully usable offline / without a
/// configured backend (see README "Run against the mock backend").
///
/// Defaults to false — the app hits the real Appwrite instance out of the
/// box. Toggle with `--dart-define=USE_MOCK_BACKEND=true` to force mocks.
final useMockBackendProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment('USE_MOCK_BACKEND', defaultValue: false);
});
