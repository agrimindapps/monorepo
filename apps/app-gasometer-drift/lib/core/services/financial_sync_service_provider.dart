import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import 'audit_trail_service.dart';
import 'financial_conflict_resolver.dart';
import 'financial_sync_service.dart';
import 'financial_validator.dart';

// Provider for FinancialAuditTrailService
final financialAuditTrailServiceProvider = Provider<FinancialAuditTrailService>(
  (ref) {
    final service = FinancialAuditTrailService();
    // Initialize will be called when service is first accessed
    service.initialize();
    return service;
  },
);

// Provider for FinancialConflictResolver
final financialConflictResolverProvider = Provider<FinancialConflictResolver>((
  ref,
) {
  final auditService = ref.watch(financialAuditTrailServiceProvider);
  return FinancialConflictResolver(auditService);
});

// Provider for FinancialSyncService - REAL implementation
final financialSyncServiceProvider = Provider<FinancialSyncService>((ref) {
  final auditService = ref.watch(financialAuditTrailServiceProvider);
  final conflictResolver = ref.watch(financialConflictResolverProvider);

  // Note: FinancialValidator has only static methods, but constructor requires instance
  // FinancialConflictResolver is also not stored but required by constructor
  final service = FinancialSyncService(
    validator: FinancialValidator(),
    auditService: auditService,
    conflictResolver: conflictResolver,
    coreSync: UnifiedSyncManager.instance,
  );

  // Initialize the service
  service.initialize().catchError((Object error) {
    SecureLogger.warning(
      'Failed to initialize FinancialSyncService',
      error: error,
    );
  });

  // Dispose on provider disposal
  ref.onDispose(() {
    service.dispose();
  });

  if (kDebugMode) {
    print('✅ FinancialSyncService initialized with real implementation');
  }

  return service;
});
