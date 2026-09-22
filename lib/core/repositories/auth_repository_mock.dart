import '../error/failure.dart';
import '../error/result.dart';
import '../models/current_user.dart';
import 'auth_repository.dart';

class AuthRepositoryMock implements AuthRepository {
  CurrentUser _user = const CurrentUser(id: 'guest', email: null, isAnonymous: true);

  @override
  Future<Result<CurrentUser>> ensureSession() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Ok(_user);
  }

  @override
  Future<Result<CurrentUser>> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (password.length < 4) {
      return const Err(InvalidCredentialsFailure());
    }
    _user = CurrentUser(id: 'user_${email.hashCode}', email: email, isAnonymous: false);
    return Ok(_user);
  }

  @override
  Future<Result<void>> signOut() async {
    _user = const CurrentUser(id: 'guest', email: null, isAnonymous: true);
    return const Ok(null);
  }
}
