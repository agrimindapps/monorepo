// Services module for app-gasometer
//
// Exports financial logging service for structured logging
// of financial operations and auditability.
//
// Usage:
// ```dart
// import 'package:gasometer/core/services/services.dart';
//
// final logger = FinancialLoggingService.withCrashlytics();
//
// logger.logFinancialOperation(
//   operation: 'CREATE',
//   entityType: 'fuel_supply',
//   entityId: 'fuel-123',
//   amount: 100.50,
// );
// ```

export '../../features/financial/domain/services/financial_logging_service.dart';
