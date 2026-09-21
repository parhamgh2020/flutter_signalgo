import 'package:appwrite/appwrite.dart';

import '../../l10n/generated/app_localizations.dart';

/// A typed, localizable failure. Repositories translate [AppwriteException]s
/// (and other errors) into one of these instead of leaking raw exceptions
/// into the presentation layer.
sealed class Failure {
  const Failure();

  factory Failure.fromAppwriteException(AppwriteException e) {
    if (e.code == 401 && (e.type?.contains('invalid_credentials') ?? false)) {
      return const InvalidCredentialsFailure();
    }
    switch (e.code) {
      case 401:
        return const UnauthorizedFailure();
      case 404:
        return const NotFoundFailure();
      case null:
        return const NetworkFailure();
      default:
        return ServerFailure(e.message ?? e.type ?? 'Unknown error');
    }
  }

  String localizedMessage(AppLocalizations l10n) {
    final self = this;
    return switch (self) {
      NetworkFailure() => l10n.errorNetwork,
      UnauthorizedFailure() => l10n.errorUnauthorized,
      NotFoundFailure() => l10n.errorNotFound,
      InvalidCredentialsFailure() => l10n.errorInvalidCredentials,
      SelfSignedCertFailure() => l10n.errorSelfSignedCert,
      ServerFailure(:final message) => l10n.errorAppwrite(message),
      UnknownFailure() => l10n.errorGeneric,
    };
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}

class SelfSignedCertFailure extends Failure {
  const SelfSignedCertFailure();
}

class ServerFailure extends Failure {
  const ServerFailure(this.message);
  final String message;
}

class UnknownFailure extends Failure {
  const UnknownFailure([this.error]);
  final Object? error;
}
