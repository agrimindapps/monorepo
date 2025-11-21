/// Audit Trail Service for Financial Data
/// Tracks changes in financial data for compliance and debugging
library;


import '../../../../core/data/models/audit_trail_model.dart';
import '../../../../database/repositories/audit_trail_repository.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../fuel/data/models/fuel_supply_model.dart';

/// Audit event types
enum AuditEventType {
  create('CREATE'),
  update('UPDATE'),
  delete('DELETE'),
  sync('SYNC'),
  conflictResolution('CONFLICT_RESOLUTION'),
  validationFailure('VALIDATION_FAILURE');

  const AuditEventType(this.value);
  final String value;
}

/// Financial Audit Trail Service - Migrated to Drift
class FinancialAuditTrailService {
  FinancialAuditTrailService(this._repository);

  final AuditTrailRepository _repository;

  static const int _retentionDays = 365; // Keep entries for 1 year

  String? _currentUserId;

  /// Initialize the audit service (no-op for Drift)
  Future<void> initialize({String? userId}) async {
    _currentUserId = userId;
    await _cleanOldEntries();
  }

  /// Set current user ID
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Log creation of financial entity
  Future<void> logCreation(dynamic entity, {String? description}) async {
    if (!_shouldAudit(entity)) return;

    final entry = AuditTrailEntry(
      id: '${_getEntityId(entity)}_${AuditEventType.create.value}_${DateTime.now().millisecondsSinceEpoch}',
      entityId: _getEntityId(entity),
      entityType: _getEntityType(entity),
      eventType: AuditEventType.create.value,
      timestamp: DateTime.now(),
      userId: _currentUserId ?? _getUserId(entity),
      beforeState: const {},
      afterState: _extractFinancialFields(entity),
      description: description ?? 'Created ${_getEntityType(entity)}',
      monetaryValue: _extractMonetaryValue(entity),
      metadata: const {},
      syncSource: 'local',
    );

    await _repository.insert(entry);
  }

  /// Log update of financial entity
  Future<void> logUpdate(
    dynamic beforeEntity,
    dynamic afterEntity, {
    String? description,
  }) async {
    if (!_shouldAudit(afterEntity)) return;

    final beforeState = _extractFinancialFields(beforeEntity);
    final afterState = _extractFinancialFields(afterEntity);
    if (_hasFinancialChanges(beforeState, afterState)) {
      final entry = AuditTrailEntry(
        id: '${_getEntityId(afterEntity)}_${AuditEventType.update.value}_${DateTime.now().millisecondsSinceEpoch}',
        entityId: _getEntityId(afterEntity),
        entityType: _getEntityType(afterEntity),
        eventType: AuditEventType.update.value,
        timestamp: DateTime.now(),
        userId: _currentUserId ?? _getUserId(afterEntity),
        beforeState: beforeState,
        afterState: afterState,
        description: description ?? 'Updated ${_getEntityType(afterEntity)}',
        monetaryValue: _extractMonetaryValue(afterEntity),
        metadata: const {},
        syncSource: 'local',
      );

      await _repository.insert(entry);
    }
  }

  /// Log deletion of financial entity
  Future<void> logDeletion(dynamic entity, {String? description}) async {
    if (!_shouldAudit(entity)) return;

    final entry = AuditTrailEntry(
      id: '${_getEntityId(entity)}_${AuditEventType.delete.value}_${DateTime.now().millisecondsSinceEpoch}',
      entityId: _getEntityId(entity),
      entityType: _getEntityType(entity),
      eventType: AuditEventType.delete.value,
      timestamp: DateTime.now(),
      userId: _currentUserId ?? _getUserId(entity),
      beforeState: _extractFinancialFields(entity),
      afterState: const {},
      description: description ?? 'Deleted ${_getEntityType(entity)}',
      monetaryValue: _extractMonetaryValue(entity),
      metadata: const {},
      syncSource: 'local',
    );

    await _repository.insert(entry);
  }

  /// Log sync operation
  Future<void> logSync(
    dynamic entity, {
    required bool success,
    String? error,
    String? syncSource,
  }) async {
    if (!_shouldAudit(entity)) return;

    final entry = AuditTrailEntry(
      id: '${_getEntityId(entity)}_${AuditEventType.sync.value}_${DateTime.now().millisecondsSinceEpoch}',
      entityId: _getEntityId(entity),
      entityType: _getEntityType(entity),
      eventType: AuditEventType.sync.value,
      timestamp: DateTime.now(),
      userId: _currentUserId ?? _getUserId(entity),
      beforeState: const {},
      afterState: _extractFinancialFields(entity),
      description: success
          ? 'Synced ${_getEntityType(entity)} successfully'
          : 'Sync failed: $error',
      monetaryValue: _extractMonetaryValue(entity),
      metadata: {
        'success': success,
        'error': error,
        'sync_timestamp': DateTime.now().toIso8601String(),
      },
      syncSource: syncSource ?? 'remote',
    );

    await _repository.insert(entry);
  }

  /// Log conflict resolution
  Future<void> logConflictResolution(
    dynamic localEntity,
    dynamic remoteEntity,
    dynamic resolvedEntity, {
    required String strategy,
    String? description,
  }) async {
    if (!_shouldAudit(resolvedEntity)) return;

    final entry = AuditTrailEntry(
      id: '${_getEntityId(resolvedEntity)}_${AuditEventType.conflictResolution.value}_${DateTime.now().millisecondsSinceEpoch}',
      entityId: _getEntityId(resolvedEntity),
      entityType: _getEntityType(resolvedEntity),
      eventType: AuditEventType.conflictResolution.value,
      timestamp: DateTime.now(),
      userId: _currentUserId ?? _getUserId(resolvedEntity),
      beforeState: {
        'local': _extractFinancialFields(localEntity),
        'remote': _extractFinancialFields(remoteEntity),
      },
      afterState: _extractFinancialFields(resolvedEntity),
      description: description ?? 'Conflict resolved using $strategy strategy',
      monetaryValue: _extractMonetaryValue(resolvedEntity),
      metadata: {
        'strategy': strategy,
        'local_version': _getVersion(localEntity),
        'remote_version': _getVersion(remoteEntity),
        'resolved_version': _getVersion(resolvedEntity),
      },
      syncSource: 'conflict_resolution',
    );

    await _repository.insert(entry);
  }

  /// Log validation failure
  Future<void> logValidationFailure(
    dynamic entity, {
    required List<String> errors,
    List<String>? warnings,
  }) async {
    if (!_shouldAudit(entity)) return;

    final entry = AuditTrailEntry(
      id: '${_getEntityId(entity)}_${AuditEventType.validationFailure.value}_${DateTime.now().millisecondsSinceEpoch}',
      entityId: _getEntityId(entity),
      entityType: _getEntityType(entity),
      eventType: AuditEventType.validationFailure.value,
      timestamp: DateTime.now(),
      userId: _currentUserId ?? _getUserId(entity),
      beforeState: const {},
      afterState: _extractFinancialFields(entity),
      description: 'Validation failed: ${errors.join('; ')}',
      monetaryValue: _extractMonetaryValue(entity),
      metadata: {
        'errors': errors,
        'warnings': warnings ?? [],
        'validation_timestamp': DateTime.now().toIso8601String(),
      },
      syncSource: 'local',
    );

    await _repository.insert(entry);
  }

  /// Get audit trail for specific entity
  Future<List<AuditTrailEntry>> getEntityAuditTrail(String entityId) async {
    return await _repository.getByEntity(entityId);
  }

  /// Get recent high-value transactions
  Future<List<AuditTrailEntry>> getHighValueTransactions({
    int days = 30,
  }) async {
    return await _repository.getHighValueTransactions(
      minValue: 1000.0,
      days: days,
    );
  }

  /// Get audit summary for date range
  Future<Map<String, dynamic>> getAuditSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final entries = await _repository.getByDateRange(start, end);

    final summary = <String, dynamic>{
      'total_entries': entries.length,
      'by_type': <String, int>{},
      'by_entity': <String, int>{},
      'high_value_count': 0,
      'total_monetary_value': 0.0,
    };

    for (final entry in entries) {
      summary['by_type'][entry.eventType] =
          (summary['by_type'][entry.eventType] ?? 0) + 1;
      summary['by_entity'][entry.entityType] =
          (summary['by_entity'][entry.entityType] ?? 0) + 1;
      if (entry.monetaryValue != null && entry.monetaryValue! > 1000.0) {
        summary['high_value_count']++;
      }
      if (entry.monetaryValue != null) {
        summary['total_monetary_value'] += entry.monetaryValue!;
      }
    }

    return summary;
  }

  /// Clean old audit entries
  Future<void> _cleanOldEntries() async {
    await _repository.cleanOldEntries(_retentionDays);
  }

  /// Check if entity should be audited
  bool _shouldAudit(dynamic entity) {
    return entity is FuelSupplyModel || entity is ExpenseModel;
  }

  /// Get entity ID
  String _getEntityId(dynamic entity) {
    if (entity is FuelSupplyModel) return entity.id;
    if (entity is ExpenseModel) return entity.id;
    return 'unknown';
  }

  /// Get user ID from entity
  String? _getUserId(dynamic entity) {
    if (entity is FuelSupplyModel) return entity.userId;
    if (entity is ExpenseModel) return entity.userId;
    return null;
  }

  /// Get version from entity
  int _getVersion(dynamic entity) {
    if (entity is FuelSupplyModel) return entity.version;
    if (entity is ExpenseModel) return entity.version;
    return 0;
  }

  /// Get entity type string
  String _getEntityType(dynamic entity) {
    if (entity is FuelSupplyModel) return 'fuel_supply';
    if (entity is ExpenseModel) return 'expense';
    return 'unknown';
  }

  /// Extract financial fields for audit
  Map<String, dynamic> _extractFinancialFields(dynamic entity) {
    if (entity is FuelSupplyModel) {
      return {
        'vehicle_id': entity.vehicleId,
        'total_price': entity.totalPrice,
        'liters': entity.liters,
        'price_per_liter': entity.pricePerLiter,
        'odometer': entity.odometer,
        'date': entity.date,
        'gas_station': entity.gasStationName,
      };
    }

    if (entity is ExpenseModel) {
      return {
        'veiculo_id': entity.veiculoId,
        'valor': entity.valor,
        'tipo': entity.tipo,
        'descricao': entity.descricao,
        'odometro': entity.odometro,
        'data': entity.data,
      };
    }

    return {};
  }

  /// Extract monetary value from entity
  double? _extractMonetaryValue(dynamic entity) {
    if (entity is FuelSupplyModel) return entity.totalPrice;
    if (entity is ExpenseModel) return entity.valor;
    return null;
  }

  /// Check if there are financial changes between states
  bool _hasFinancialChanges(
    Map<String, dynamic> before,
    Map<String, dynamic> after,
  ) {
    final financialKeys = ['total_price', 'liters', 'price_per_liter', 'valor'];

    for (final key in financialKeys) {
      if (before[key] != after[key]) return true;
    }

    return false;
  }

  /// Close the audit service (no-op for Drift)
  Future<void> close() async {
    // No-op for Drift
  }
}
