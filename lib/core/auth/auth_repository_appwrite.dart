import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../error/failure.dart';
import '../error/result.dart';
import 'auth_repository.dart';
import 'current_user.dart';

class AuthRepositoryAppwrite implements AuthRepository {
  AuthRepositoryAppwrite({required Account account}) : _account = account;

  final Account _account;

  CurrentUser _toCurrentUser(models.User user) {
    return CurrentUser(
      id: user.$id,
      email: user.email.isEmpty ? null : user.email,
      isAnonymous: user.email.isEmpty,
    );
  }

  @override
  Future<Result<CurrentUser>> ensureSession() async {
    try {
      final user = await _account.get();
      return Ok(_toCurrentUser(user));
    } on AppwriteException catch (e) {
      if (e.code != 401) return Err(Failure.fromAppwriteException(e));
      try {
        await _account.createAnonymousSession();
        final user = await _account.get();
        return Ok(_toCurrentUser(user));
      } on AppwriteException catch (e2) {
        return Err(Failure.fromAppwriteException(e2));
      }
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<CurrentUser>> signInWithEmail(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(email: email, password: password);
      final user = await _account.get();
      return Ok(_toCurrentUser(user));
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      return const Ok(null);
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }
}
