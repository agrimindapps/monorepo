/// Exception thrown when cache operations fail
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when server operations fail
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException([this.message = 'Server error occurred', this.statusCode]);

  @override
  String toString() => 'ServerException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

/// Exception thrown when network operations fail
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => 'NetworkException: $message';
}
