/// Base exception class for all app exceptions
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

// ==================== Server Exceptions ====================

class ServerException extends AppException {
  const ServerException({
    String message = 'Server error occurred',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Cache Exceptions ====================

class CacheException extends AppException {
  const CacheException({
    String message = 'Cache error occurred',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Network Exceptions ====================

class NetworkException extends AppException {
  const NetworkException({
    String message = 'Network error occurred',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Storage Exceptions ====================

class StorageException extends AppException {
  const StorageException({
    String message = 'Storage error occurred',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class StorageReadException extends StorageException {
  const StorageReadException({
    String message = 'Failed to read from storage',
  }) : super(message: message);
}

class StorageWriteException extends StorageException {
  const StorageWriteException({
    String message = 'Failed to write to storage',
  }) : super(message: message);
}

class StorageDeleteException extends StorageException {
  const StorageDeleteException({
    String message = 'Failed to delete from storage',
  }) : super(message: message);
}

// ==================== Data Exceptions ====================

class DataNotFoundException extends AppException {
  const DataNotFoundException({
    String message = 'Data not found',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class DataParseException extends AppException {
  const DataParseException({
    String message = 'Failed to parse data',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Validation Exceptions ====================

class ValidationException extends AppException {
  const ValidationException({
    String message = 'Validation failed',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Permission Exceptions ====================

class PermissionException extends AppException {
  const PermissionException({
    String message = 'Permission denied',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

// ==================== Premium Exceptions ====================

class PremiumException extends AppException {
  const PremiumException({
    String message = 'Premium feature error',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class SubscriptionNotFoundException extends PremiumException {
  const SubscriptionNotFoundException({
    String message = 'Subscription not found',
  }) : super(message: message);
}

class PurchaseException extends PremiumException {
  const PurchaseException({
    String message = 'Purchase failed',
  }) : super(message: message);
}
