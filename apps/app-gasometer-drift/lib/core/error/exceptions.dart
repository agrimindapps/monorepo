class ServerException implements Exception {
  const ServerException(this.message);
  final String message;
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  const AuthenticationException(this.message);
  final String message;
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException implements Exception {
  const AuthorizationException(this.message);
  final String message;
  
  @override
  String toString() => 'AuthorizationException: $message';
}

class VehicleNotFoundException implements Exception {
  const VehicleNotFoundException(this.message);
  final String message;
  
  @override
  String toString() => 'VehicleNotFoundException: $message';
}

class SyncException implements Exception {
  const SyncException(this.message);
  final String message;
  
  @override
  String toString() => 'SyncException: $message';
}
