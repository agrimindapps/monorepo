/// Financial Core Module for GasOMeter
/// Exports all financial-related services, validators, and widgets
library;

import 'package:core/core.dart';

import 'audit_trail_service.dart';
import 'financial_conflict_resolver.dart';
import 'financial_sync_service.dart';
import 'financial_validator.dart';

export '../../features/expenses/data/models/expense_model.dart';
// Core entities (re-export from features)
export '../../features/fuel/data/models/fuel_supply_model.dart';
// Services
export 'audit_trail_service.dart';
export 'financial_conflict_resolver.dart';
export 'financial_sync_service.dart';
export 'financial_validator.dart';
// Widgets
export '../../shared/widgets/financial_conflict_dialog.dart';
export '../../shared/widgets/financial_sync_indicator.dart';
export '../../shared/widgets/financial_warning_banner.dart';

/// Financial module configuration and initialization
class FinancialModule {
  static FinancialAuditTrailService? _auditService;
  static FinancialConflictResolver? _conflictResolver;
  static FinancialSyncService? _syncService;

  /// Initialize the financial module
  static Future<void> initialize({
    required String userId,
    required UnifiedSyncManager coreSync,
  }) async {
    // Initialize audit service
    _auditService = FinancialAuditTrailService();
    await _auditService!.initialize(userId: userId);

    // Initialize conflict resolver
    _conflictResolver = FinancialConflictResolver(_auditService!);

    // Initialize sync service
    _syncService = FinancialSyncService(
      validator: FinancialValidator(),
      auditService: _auditService!,
      conflictResolver: _conflictResolver!,
      coreSync: coreSync,
    );

    await _syncService!.initialize();
  }

  /// Get audit service instance
  static FinancialAuditTrailService get auditService {
    if (_auditService == null) {
      throw StateError('Financial module not initialized. Call FinancialModule.initialize() first.');
    }
    return _auditService!;
  }

  /// Get conflict resolver instance
  static FinancialConflictResolver get conflictResolver {
    if (_conflictResolver == null) {
      throw StateError('Financial module not initialized. Call FinancialModule.initialize() first.');
    }
    return _conflictResolver!;
  }

  /// Get sync service instance
  static FinancialSyncService get syncService {
    if (_syncService == null) {
      throw StateError('Financial module not initialized. Call FinancialModule.initialize() first.');
    }
    return _syncService!;
  }

  /// Check if module is initialized
  static bool get isInitialized =>
      _auditService != null && _conflictResolver != null && _syncService != null;

  /// Dispose the financial module
  static Future<void> dispose() async {
    await _auditService?.close();
    _syncService?.dispose();

    _auditService = null;
    _conflictResolver = null;
    _syncService = null;
  }

  /// Set user ID for all services
  static void setUserId(String userId) {
    _auditService?.setUserId(userId);
  }

  /// Quick access methods for common operations

  /// Validate financial entity
  static FinancialValidationResult validateEntity(BaseSyncEntity entity) {
    return FinancialValidator.validateForSync(entity);
  }

  /// Queue entity for financial sync
  static Future<FinancialSyncResult> syncEntity(BaseSyncEntity entity) {
    return syncService.queueForSync(entity);
  }

  /// Force immediate sync for critical financial data
  static Future<FinancialSyncResult> syncImmediately(BaseSyncEntity entity) {
    return syncService.syncImmediately(entity);
  }

  /// Get sync status for entity
  static FinancialSyncStatus getSyncStatus(String entityId) {
    return syncService.getSyncStatus(entityId);
  }

  /// Get financial sync statistics
  static Map<String, dynamic> getSyncStats() {
    return syncService.getQueueStats();
  }

  /// Get audit trail for entity
  static List<FinancialAuditEntry> getAuditTrail(String entityId) {
    return auditService.getEntityAuditTrail(entityId);
  }

  /// Get high-value transactions audit
  static List<FinancialAuditEntry> getHighValueTransactions({int days = 30}) {
    return auditService.getHighValueTransactions(days: days);
  }

  /// Get audit summary
  static Map<String, dynamic> getAuditSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return auditService.getAuditSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Resolve financial conflict
  static Future<FinancialConflictResult> resolveConflict(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity, {
    FinancialConflictStrategy? preferredStrategy,
    Map<String, dynamic>? userContext,
  }) {
    return conflictResolver.resolveConflict(
      localEntity,
      remoteEntity,
      preferredStrategy: preferredStrategy,
      userContext: userContext,
    );
  }

  /// Get recommended conflict resolution strategy
  static FinancialConflictStrategy getRecommendedStrategy(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
  ) {
    return conflictResolver.getRecommendedStrategy(localEntity, remoteEntity);
  }
}