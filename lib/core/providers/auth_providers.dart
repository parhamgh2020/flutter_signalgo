import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../appwrite/appwrite_client.dart';
import '../appwrite/health_service.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_repository_appwrite.dart';
import '../auth/auth_repository_mock.dart';
import '../auth/current_user.dart';
import '../error/failure.dart';
import 'repo_mode_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) {
    return AuthRepositoryMock();
  }
  return AuthRepositoryAppwrite(account: ref.watch(appwriteAccountProvider));
});

class AuthController extends AsyncNotifier<CurrentUser?> {
  @override
  FutureOr<CurrentUser?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final result = await repo.ensureSession();
    return result.fold((user) => user, (_) => null);
  }

  /// Returns null on success, or the [Failure] to show inline on the form.
  Future<Failure?> signIn(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithEmail(email, password);
    return result.fold((user) {
      state = AsyncData(user);
      return null;
    }, (failure) => failure);
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    ref.invalidateSelf();
    await future;
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, CurrentUser?>(AuthController.new);

final backendStatusProvider = FutureProvider.autoDispose<BackendStatus>((ref) async {
  if (ref.watch(useMockBackendProvider)) return BackendStatus.online;
  return HealthService(ref.watch(appwriteConfigProvider)).ping();
});
