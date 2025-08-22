// Base exception class
abstract class BaseException implements Exception {
  final String message;
  final int? statusCode;
  
  const BaseException(this.message, {this.statusCode});
  
  @override
  String toString() => 'Exception: $message';
}

// Server exception for API errors
class ServerException extends BaseException {
  const ServerException(super.message, {super.statusCode});
  
  factory ServerException.fromDioError(String message, {int? statusCode}) {
    return ServerException(message, statusCode: statusCode);
  }
}

// Network exception for connectivity issues
class NetworkException extends BaseException {
  const NetworkException(super.message, {super.statusCode});
}

// Cache exception for local storage issues
class CacheException extends BaseException {
  const CacheException(super.message, {super.statusCode});
}

// Validation exception for input validation
class ValidationException extends BaseException {
  const ValidationException(super.message, {super.statusCode});
}

// Unknown exception for unexpected errors
class UnknownException extends BaseException {
  const UnknownException(super.message, {super.statusCode});
}

// GeneralException maps to UnknownException
typedef GeneralException = UnknownException;