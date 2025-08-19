class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException implements Exception {
  final String message;
  const AuthorizationException(this.message);
  
  @override
  String toString() => 'AuthorizationException: $message';
}

class VehicleNotFoundException implements Exception {
  final String message;
  const VehicleNotFoundException(this.message);
  
  @override
  String toString() => 'VehicleNotFoundException: $message';
}

class SyncException implements Exception {
  final String message;
  const SyncException(this.message);
  
  @override
  String toString() => 'SyncException: $message';
}