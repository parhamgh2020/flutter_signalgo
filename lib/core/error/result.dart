import 'failure.dart';

/// A minimal Either-style result type. Repositories return `Result<T>`
/// instead of throwing, so the presentation layer always handles the
/// failure path explicitly.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => Ok(transform(value)),
      Err<T>(:final failure) => Err(failure),
    };
  }

  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
