class ServerException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const ServerException({
    required this.message,
    this.code,
    this.details,
  });
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const CacheException({
    required this.message,
    this.code,
    this.details,
  });
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const NetworkException({
    required this.message,
    this.code,
    this.details,
  });
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;
  
  const ValidationException({
    required this.message,
    this.errors,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'AuthException: $message';
}