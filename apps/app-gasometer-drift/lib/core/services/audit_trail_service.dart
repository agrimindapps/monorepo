/// Audit Trail Service for Financial Data
/// Tracks changes in financial data for compliance and debugging
library;

import 'package:core/core.dart';

import '../../features/expenses/data/models/expense_model.dart';
import '../../features/fuel/data/models/fuel_supply_model.dart';

part 'audit_trail_service.g.dart';

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

/// Audit trail entry for financial operations
@HiveType(typeId: 50)
class FinancialAuditEntry extends HiveObject {
  // 'local', 'remote', 'conflict_resolution'

  FinancialAuditEntry({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.eventType,
    required this.timestamp,
    this.userId,
    this.beforeState = const {},
    this.afterState = const {},
    this.description,
    this.monetaryValue,
    this.metadata = const {},
    this.syncSource,
  });

  factory FinancialAuditEntry.create({
    required String entityId,
    required String entityType,
    required AuditEventType eventType,
    String? userId,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    String? description,
    double? monetaryValue,
    Map<String, dynamic>? metadata,
    String? syncSource,
  }) {
    final now = DateTime.now();
    return FinancialAuditEntry(
      id: '${entityId}_${eventType.value}_${now.millisecondsSinceEpoch}',
      entityId: entityId,
      entityType: entityType,
      eventType: eventType.value,
      timestamp: now.millisecondsSinceEpoch,
      userId: userId,
      beforeState: beforeState ?? {},
      afterState: afterState ?? {},
      description: description,
      monetaryValue: monetaryValue,
      metadata: metadata ?? {},
      syncSource: syncSource,
    );
  }
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entityId;

  @HiveField(2)
  final String entityType;

  @HiveField(3)
  final String eventType;

  @HiveField(4)
  final int timestamp;

  @HiveField(5)
  final String? userId;

  @HiveField(6)
  final Map<String, dynamic> beforeState;

  @HiveField(7)
  final Map<String, dynamic> afterState;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final double? monetaryValue;

  @HiveField(10)
  final Map<String, dynamic> metadata;

  @HiveField(11)
  final String? syncSource;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  /// Check if this is a high-value transaction
  bool get isHighValue => monetaryValue != null && monetaryValue! > 1000.0;

  /// Get formatted monetary value
  String get formattedValue => monetaryValue != null
      ? 'R\$ ${monetaryValue!.toStringAsFixed(2)}'
      : 'N/A';

  @override
  String toString() {
    return 'FinancialAuditEntry(entityId: $entityId, eventType: $eventType, monetaryValue: $formattedValue)';
  }
}

/// Financial Audit Trail Service
class FinancialAuditTrailService {
  static const String _boxName = 'financial_audit_trail';
  static const int _maxEntriesPerEntity =
      100; // Keep last 100 entries per entity
  static const int _retentionDays = 365; // Keep entries for 1 year

  Box<FinancialAuditEntry>? _auditBox;
  String? _currentUserId;

  /// Initialize the audit service
  Future<void> initialize({String? userId}) async {
    _currentUserId = userId;

    if (!Hive.isBoxOpen(_boxName)) {
      _auditBox = await Hive.openBox<FinancialAuditEntry>(_boxName);
    } else {
      _auditBox = Hive.box<FinancialAuditEntry>(_boxName);
    }
    await _cleanOldEntries();
  }

  /// Set current user ID
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  /// Log creation of financial entity
  Future<void> logCreation(BaseSyncEntity entity, {String? description}) async {
    if (!_shouldAudit(entity)) return;

    final entry = FinancialAuditEntry.create(
      entityId: entity.id,
      entityType: _getEntityType(entity),
      eventType: AuditEventType.create,
      userId: _currentUserId ?? entity.userId,
      afterState: _extractFinancialFields(entity),
      description: description ?? 'Created ${_getEntityType(entity)}',
      monetaryValue: _extractMonetaryValue(entity),
      syncSource: 'local',
    );

    await _saveEntry(entry);
  }

  /// Log update of financial entity
  Future<void> logUpdate(
    BaseSyncEntity beforeEntity,
    BaseSyncEntity afterEntity, {
    String? description,
  }) async {
    if (!_shouldAudit(afterEntity)) return;

    final beforeState = _extractFinancialFields(beforeEntity);
    final afterState = _extractFinancialFields(afterEntity);
    if (_hasFinancialChanges(beforeState, afterState)) {
      final entry = FinancialAuditEntry.create(
        entityId: afterEntity.id,
        entityType: _getEntityType(afterEntity),
        eventType: AuditEventType.update,
        userId: _currentUserId ?? afterEntity.userId,
        beforeState: beforeState,
        afterState: afterState,
        description: description ?? 'Updated ${_getEntityType(afterEntity)}',
        monetaryValue: _extractMonetaryValue(afterEntity),
        syncSource: 'local',
      );

      await _saveEntry(entry);
    }
  }

  /// Log deletion of financial entity
  Future<void> logDeletion(BaseSyncEntity entity, {String? description}) async {
    if (!_shouldAudit(entity)) return;

    final entry = FinancialAuditEntry.create(
      entityId: entity.id,
      entityType: _getEntityType(entity),
      eventType: AuditEventType.delete,
      userId: _currentUserId ?? entity.userId,
      beforeState: _extractFinancialFields(entity),
      description: description ?? 'Deleted ${_getEntityType(entity)}',
      monetaryValue: _extractMonetaryValue(entity),
      syncSource: 'local',
    );

    await _saveEntry(entry);
  }

  /// Log sync operation
  Future<void> logSync(
    BaseSyncEntity entity, {
    required bool success,
    String? error,
    String? syncSource,
  }) async {
    if (!_shouldAudit(entity)) return;

    final entry = FinancialAuditEntry.create(
      entityId: entity.id,
      entityType: _getEntityType(entity),
      eventType: AuditEventType.sync,
      userId: _currentUserId ?? entity.userId,
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

    await _saveEntry(entry);
  }

  /// Log conflict resolution
  Future<void> logConflictResolution(
    BaseSyncEntity localEntity,
    BaseSyncEntity remoteEntity,
    BaseSyncEntity resolvedEntity, {
    required String strategy,
    String? description,
  }) async {
    if (!_shouldAudit(resolvedEntity)) return;

    final entry = FinancialAuditEntry.create(
      entityId: resolvedEntity.id,
      entityType: _getEntityType(resolvedEntity),
      eventType: AuditEventType.conflictResolution,
      userId: _currentUserId ?? resolvedEntity.userId,
      beforeState: {
        'local': _extractFinancialFields(localEntity),
        'remote': _extractFinancialFields(remoteEntity),
      },
      afterState: _extractFinancialFields(resolvedEntity),
      description: description ?? 'Conflict resolved using $strategy strategy',
      monetaryValue: _extractMonetaryValue(resolvedEntity),
      metadata: {
        'strategy': strategy,
        'local_version': localEntity.version,
        'remote_version': remoteEntity.version,
        'resolved_version': resolvedEntity.version,
      },
      syncSource: 'conflict_resolution',
    );

    await _saveEntry(entry);
  }

  /// Log validation failure
  Future<void> logValidationFailure(
    BaseSyncEntity entity, {
    required List<String> errors,
    List<String>? warnings,
  }) async {
    if (!_shouldAudit(entity)) return;

    final entry = FinancialAuditEntry.create(
      entityId: entity.id,
      entityType: _getEntityType(entity),
      eventType: AuditEventType.validationFailure,
      userId: _currentUserId ?? entity.userId,
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

    await _saveEntry(entry);
  }

  /// Get audit trail for specific entity
  List<FinancialAuditEntry> getEntityAuditTrail(String entityId) {
    if (_auditBox == null) return [];

    return _auditBox!.values
        .where((entry) => entry.entityId == entityId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get recent high-value transactions
  List<FinancialAuditEntry> getHighValueTransactions({int days = 30}) {
    if (_auditBox == null) return [];

    final cutoff = DateTime.now().subtract(Duration(days: days));

    return _auditBox!.values
        .where((entry) => entry.isHighValue && entry.dateTime.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get audit summary for date range
  Map<String, dynamic> getAuditSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (_auditBox == null) return {};

    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final entries = _auditBox!.values
        .where(
          (entry) =>
              entry.dateTime.isAfter(start) && entry.dateTime.isBefore(end),
        )
        .toList();

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
      if (entry.isHighValue) {
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
    if (_auditBox == null) return;

    final cutoff = DateTime.now().subtract(
      const Duration(days: _retentionDays),
    );
    final keysToDelete = <dynamic>[];

    for (final entry in _auditBox!.values) {
      if (entry.dateTime.isBefore(cutoff)) {
        keysToDelete.add(entry.key);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _auditBox!.deleteAll(keysToDelete);
    }
    await _limitEntriesPerEntity();
  }

  /// Limit number of entries per entity
  Future<void> _limitEntriesPerEntity() async {
    if (_auditBox == null) return;

    final entitiesMap = <String, List<FinancialAuditEntry>>{};
    for (final entry in _auditBox!.values) {
      entitiesMap.putIfAbsent(entry.entityId, () => []).add(entry);
    }
    for (final entityId in entitiesMap.keys) {
      final entries = entitiesMap[entityId]!;
      if (entries.length > _maxEntriesPerEntity) {
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final toDelete = entries.skip(_maxEntriesPerEntity);

        final keysToDelete = toDelete.map((e) => e.key).toList();
        await _auditBox!.deleteAll(keysToDelete);
      }
    }
  }

  /// Save audit entry
  Future<void> _saveEntry(FinancialAuditEntry entry) async {
    if (_auditBox == null) return;
    await _auditBox!.put(entry.id, entry);
  }

  /// Check if entity should be audited
  bool _shouldAudit(BaseSyncEntity entity) {
    return entity is FuelSupplyModel || entity is ExpenseModel;
  }

  /// Get entity type string
  String _getEntityType(BaseSyncEntity entity) {
    if (entity is FuelSupplyModel) return 'fuel_supply';
    if (entity is ExpenseModel) return 'expense';
    return 'unknown';
  }

  /// Extract financial fields for audit
  Map<String, dynamic> _extractFinancialFields(BaseSyncEntity entity) {
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
  double? _extractMonetaryValue(BaseSyncEntity entity) {
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

  /// Close the audit service
  Future<void> close() async {
    if (_auditBox?.isOpen == true) {
      await _auditBox!.close();
    }
  }
}
