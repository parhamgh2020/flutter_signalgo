import '../error/result.dart';
import 'current_user.dart';

abstract class AuthRepository {
  /// Returns the current session, creating an anonymous one if none exists.
  Future<Result<CurrentUser>> ensureSession();

  Future<Result<CurrentUser>> signInWithEmail(String email, String password);

  Future<Result<void>> signOut();
}
