import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../appwrite/appwrite_client.dart';
import '../appwrite/health_service.dart';
import '../error/failure.dart';
import '../models/current_user.dart';
import '../providers/repo_mode_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_appwrite.dart';
import '../repositories/auth_repository_mock.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) {
    return AuthRepositoryMock();
  }
  return AuthRepositoryAppwrite(account: ref.watch(appwriteAccountProvider));
});

class AuthViewModel extends AsyncNotifier<CurrentUser?> {
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

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, CurrentUser?>(AuthViewModel.new);

final backendStatusProvider = FutureProvider.autoDispose<BackendStatus>((ref) async {
  if (ref.watch(useMockBackendProvider)) return BackendStatus.online;
  return HealthService(ref.watch(appwriteConfigProvider)).ping();
});
