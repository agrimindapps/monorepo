abstract class BaseException implements Exception {
  final String message;
  final int? statusCode;
  
  const BaseException(this.message, {this.statusCode});
  
  @override
  String toString() => 'Exception: $message';
}
class ServerException extends BaseException {
  const ServerException(super.message, {super.statusCode});
  
  factory ServerException.fromDioError(String message, {int? statusCode}) {
    return ServerException(message, statusCode: statusCode);
  }
}
class NetworkException extends BaseException {
  const NetworkException(super.message, {super.statusCode});
}
class CacheException extends BaseException {
  const CacheException(super.message, {super.statusCode});
}
class ValidationException extends BaseException {
  const ValidationException(super.message, {super.statusCode});
}
class UnknownException extends BaseException {
  const UnknownException(super.message, {super.statusCode});
}
typedef GeneralException = UnknownException;