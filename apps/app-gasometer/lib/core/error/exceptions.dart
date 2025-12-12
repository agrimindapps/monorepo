abstract class GasometerException implements Exception {
  const GasometerException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends GasometerException {
  const ServerException(super.message);
}

class CacheException extends GasometerException {
  const CacheException(super.message);
}

class NetworkException extends GasometerException {
  const NetworkException(super.message);
}

class ValidationException extends GasometerException {
  const ValidationException(super.message);
}

class AuthenticationException extends GasometerException {
  const AuthenticationException(super.message);
}

class AuthorizationException extends GasometerException {
  const AuthorizationException(super.message);
}

class VehicleNotFoundException extends GasometerException {
  const VehicleNotFoundException(super.message);
}

class NotFoundException extends GasometerException {
  const NotFoundException(super.message);
}

class SyncException extends GasometerException {
  const SyncException(super.message);
}

class ParseException extends GasometerException {
  const ParseException(super.message);
}
