/// Tipo utilitário para representar o resultado de operações que podem falhar.
///
/// Segue o padrão "Result" recomendado em
/// https://docs.flutter.dev/app-architecture/design-patterns/result
///
/// ```dart
/// switch (result) {
///   case Ok(): print(result.value);
///   case Error(): print(result.error);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Cria um [Result] de sucesso contendo [value].
  const factory Result.ok(T value) = Ok._;

  /// Cria um [Result] de erro contendo [error].
  const factory Result.error(Exception error) = Error._;
}

/// Subclasse de [Result] para valores de sucesso.
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclasse de [Result] para erros.
final class Error<T> extends Result<T> {
  const Error._(this.error);

  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
