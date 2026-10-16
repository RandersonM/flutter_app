/// Typed failures the data layer throws when the cause matters to the caller.
///
/// They carry no user-facing text: BLoCs map them to a failure enum and the
/// widget localizes it. Anything else propagates as the original exception.
sealed class AppException implements Exception {
  const AppException();
}

/// The operation needs a signed-in user and there is none.
final class NotSignedInException extends AppException {
  const NotSignedInException();

  @override
  String toString() => 'NotSignedInException';
}

/// The record the caller asked for does not exist.
final class NotFoundException extends AppException {
  const NotFoundException(this.resource);

  /// What was missing, for logs only (e.g. `crew c1`).
  final String resource;

  @override
  String toString() => 'NotFoundException($resource)';
}
