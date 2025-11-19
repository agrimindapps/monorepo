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
    super.message = 'Server error occurred',
    super.statusCode,
  });
}

// ==================== Cache Exceptions ====================

class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.statusCode,
  });
}

// ==================== Network Exceptions ====================

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error occurred',
    super.statusCode,
  });
}

// ==================== Storage Exceptions ====================

class StorageException extends AppException {
  const StorageException({
    super.message = 'Storage error occurred',
    super.statusCode,
  });
}

class StorageReadException extends StorageException {
  const StorageReadException({
    super.message = 'Failed to read from storage',
  });
}

class StorageWriteException extends StorageException {
  const StorageWriteException({
    super.message = 'Failed to write to storage',
  });
}

class StorageDeleteException extends StorageException {
  const StorageDeleteException({
    super.message = 'Failed to delete from storage',
  });
}

// ==================== Data Exceptions ====================

class DataNotFoundException extends AppException {
  const DataNotFoundException({
    super.message = 'Data not found',
    super.statusCode,
  });
}

class DataParseException extends AppException {
  const DataParseException({
    super.message = 'Failed to parse data',
    super.statusCode,
  });
}

// ==================== Validation Exceptions ====================

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed',
    super.statusCode,
  });
}

// ==================== Permission Exceptions ====================

class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.statusCode,
  });
}

// ==================== Premium Exceptions ====================

class PremiumException extends AppException {
  const PremiumException({
    super.message = 'Premium feature error',
    super.statusCode,
  });
}

class SubscriptionNotFoundException extends PremiumException {
  const SubscriptionNotFoundException({
    super.message = 'Subscription not found',
  });
}

class PurchaseException extends PremiumException {
  const PurchaseException({
    super.message = 'Purchase failed',
  });
}
