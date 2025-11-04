/// Base exception class
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Server/Network related exceptions
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Cache/Local storage exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Permission/Auth exceptions
class PermissionException extends AppException {
  const PermissionException(super.message);
}
