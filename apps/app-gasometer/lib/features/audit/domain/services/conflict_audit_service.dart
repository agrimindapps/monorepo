import '../../../../core/sync/conflict_resolution_strategy.dart';
import '../../../../core/data/models/base_sync_model.dart';

/// Interface para logging (compatível com LoggingService do core se existir)
abstract class LoggingService {
  void info(String message);
  void warning(String message);
  void error(String message);
}

/// Entry de auditoria para conflitos resolvidos
class ConflictAuditEntry {
  final String id;
  final DateTime timestamp;
  final String entityType;
  final String entityId;
  final ConflictAction resolution;
  final String? localVersion;
  final String? remoteVersion;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? remoteData;
  final Map<String, dynamic>? mergedData;
  final String? notes;

  ConflictAuditEntry({
    required this.id,
    required this.timestamp,
    required this.entityType,
    required this.entityId,
    required this.resolution,
    this.localVersion,
    this.remoteVersion,
    this.localData,
    this.remoteData,
    this.mergedData,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'entityType': entityType,
      'entityId': entityId,
      'resolution': resolution.toString(),
      'localVersion': localVersion,
      'remoteVersion': remoteVersion,
      'localData': localData,
      'remoteData': remoteData,
      'mergedData': mergedData,
      'notes': notes,
    };
  }

  factory ConflictAuditEntry.fromJson(Map<String, dynamic> json) {
    return ConflictAuditEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      resolution: ConflictAction.values.firstWhere(
        (e) => e.toString() == json['resolution'],
      ),
      localVersion: json['localVersion'] as String?,
      remoteVersion: json['remoteVersion'] as String?,
      localData: json['localData'] as Map<String, dynamic>?,
      remoteData: json['remoteData'] as Map<String, dynamic>?,
      mergedData: json['mergedData'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
    );
  }
}

/// Serviço de auditoria para conflitos de sincronização
/// Registra todos os conflitos detectados e como foram resolvidos
class ConflictAuditService {
  final dynamic _logger; // dynamic para aceitar qualquer logger compatível
  final List<ConflictAuditEntry> _auditLog = [];

  // Limite de entradas mantidas em memória
  static const int _maxInMemoryEntries = 100;

  ConflictAuditService(this._logger);

  /// Registra um conflito resolvido no log de auditoria
  void logConflict<T extends BaseSyncModel>({
    required String entityType,
    required String entityId,
    required T localEntity,
    required T remoteEntity,
    required ConflictAction resolution,
    T? mergedEntity,
    String? additionalNotes,
  }) {
    final entry = ConflictAuditEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_$entityId',
      timestamp: DateTime.now(),
      entityType: entityType,
      entityId: entityId,
      resolution: resolution,
      localVersion: _extractVersion(localEntity),
      remoteVersion: _extractVersion(remoteEntity),
      localData: _extractRelevantData(localEntity),
      remoteData: _extractRelevantData(remoteEntity),
      mergedData: mergedEntity != null
          ? _extractRelevantData(mergedEntity)
          : null,
      notes: additionalNotes,
    );

    // Adiciona ao log em memória
    _auditLog.add(entry);

    // Limita tamanho do log em memória
    if (_auditLog.length > _maxInMemoryEntries) {
      _auditLog.removeAt(0); // Remove o mais antigo
    }

    // Log detalhado para debugging
    _logDetailedConflict(entry, localEntity, remoteEntity);

    // Log extra para dados financeiros (crítico para auditoria)
    if (_isFinancialEntity(entityType)) {
      _logFinancialConflict(entry, localEntity, remoteEntity, mergedEntity);
    }
  }

  /// Log detalhado do conflito no console/arquivo
  void _logDetailedConflict(
    ConflictAuditEntry entry,
    BaseSyncModel local,
    BaseSyncModel remote,
  ) {
    _logger.warning('''
[ConflictAudit] Conflict detected:
  Type: ${entry.entityType}
  ID: ${entry.entityId}
  Local version: ${entry.localVersion}
  Remote version: ${entry.remoteVersion}
  Resolution: ${entry.resolution}
  Timestamp: ${entry.timestamp}
  Local isDirty: ${local.isDirty}
  Remote isDirty: ${remote.isDirty}
''');
  }

  /// Log específico para entidades financeiras (FuelSupply, Maintenance)
  void _logFinancialConflict(
    ConflictAuditEntry entry,
    BaseSyncModel local,
    BaseSyncModel remote,
    BaseSyncModel? merged,
  ) {
    final localValue = _extractFinancialValue(local);
    final remoteValue = _extractFinancialValue(remote);
    final mergedValue = merged != null ? _extractFinancialValue(merged) : null;

    _logger.warning('''
[ConflictAudit] FINANCIAL DATA CONFLICT:
  Type: ${entry.entityType}
  ID: ${entry.entityId}
  Local value: R\$ ${localValue?.toStringAsFixed(2) ?? 'N/A'}
  Remote value: R\$ ${remoteValue?.toStringAsFixed(2) ?? 'N/A'}
  ${mergedValue != null ? 'Merged value: R\$ ${mergedValue.toStringAsFixed(2)}' : ''}
  Resolution: ${entry.resolution == ConflictAction.keepLocal
        ? 'KEPT LOCAL'
        : entry.resolution == ConflictAction.keepRemote
        ? 'KEPT REMOTE'
        : 'MERGED'}
  ⚠️ Financial data conflict requires attention!
''');

    // Se valores são diferentes, alerta extra
    if (localValue != null &&
        remoteValue != null &&
        (localValue - remoteValue).abs() > 0.01) {
      _logger.error('''
[ConflictAudit] ⚠️ ALERT: Financial values differ!
  Difference: R\$ ${(localValue - remoteValue).abs().toStringAsFixed(2)}
''');
    }
  }

  /// Extrai versão da entidade (version ou updatedAt)
  String? _extractVersion(BaseSyncModel entity) {
    final version = entity.version.toString();
    final updatedAt = entity.updatedAt?.toIso8601String() ?? 'null';
    return 'v$version @ $updatedAt';
  }

  /// Extrai dados relevantes da entidade (resumo)
  Map<String, dynamic> _extractRelevantData(BaseSyncModel entity) {
    return {
      'id': entity.id,
      'version': entity.version,
      'updatedAt': entity.updatedAt?.toIso8601String(),
      'isDirty': entity.isDirty,
      'isDeleted': entity.isDeleted,
    };
  }

  /// Extrai valor financeiro da entidade (se aplicável)
  double? _extractFinancialValue(BaseSyncModel entity) {
    // Não é possível extrair valor financeiro de forma genérica
    // sem acesso aos campos específicos do modelo.
    // Esta funcionalidade precisa ser implementada nas subclasses
    // ou através de reflexão/codegen.
    return null;
  }

  /// Verifica se é entidade financeira
  bool _isFinancialEntity(String entityType) {
    return entityType == 'fuel_supply' ||
        entityType == 'FuelSupplyModel' ||
        entityType == 'maintenance' ||
        entityType == 'MaintenanceModel';
  }

  /// Retorna os conflitos mais recentes
  List<ConflictAuditEntry> getRecentConflicts({int limit = 50}) {
    final sortedLog = List<ConflictAuditEntry>.from(_auditLog)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedLog.take(limit).toList();
  }

  /// Retorna conflitos de um tipo específico de entidade
  List<ConflictAuditEntry> getConflictsByEntityType(String entityType) {
    return _auditLog.where((entry) => entry.entityType == entityType).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Retorna conflitos de uma entidade específica (por ID)
  List<ConflictAuditEntry> getConflictsByEntityId(String entityId) {
    return _auditLog.where((entry) => entry.entityId == entityId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Retorna estatísticas de conflitos
  ConflictStatistics getStatistics() {
    final total = _auditLog.length;
    final byAction = <ConflictAction, int>{};
    final byType = <String, int>{};

    for (final entry in _auditLog) {
      byAction[entry.resolution] = (byAction[entry.resolution] ?? 0) + 1;
      byType[entry.entityType] = (byType[entry.entityType] ?? 0) + 1;
    }

    return ConflictStatistics(
      totalConflicts: total,
      conflictsByAction: byAction,
      conflictsByType: byType,
      lastConflictAt: _auditLog.isNotEmpty ? _auditLog.last.timestamp : null,
    );
  }

  /// Limpa o log de auditoria
  void clearAuditLog() {
    _logger.info(
      '[ConflictAudit] Clearing audit log (${_auditLog.length} entries)',
    );
    _auditLog.clear();
  }

  /// Conta total de conflitos registrados
  int countConflicts() => _auditLog.length;

  /// Exporta log de auditoria como JSON (para backup/análise)
  List<Map<String, dynamic>> exportAuditLog() {
    return _auditLog.map((entry) => entry.toJson()).toList();
  }
}

/// Estatísticas de conflitos
class ConflictStatistics {
  final int totalConflicts;
  final Map<ConflictAction, int> conflictsByAction;
  final Map<String, int> conflictsByType;
  final DateTime? lastConflictAt;

  ConflictStatistics({
    required this.totalConflicts,
    required this.conflictsByAction,
    required this.conflictsByType,
    this.lastConflictAt,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Conflict Statistics:');
    buffer.writeln('  Total conflicts: $totalConflicts');
    buffer.writeln('  By action:');
    conflictsByAction.forEach((action, count) {
      buffer.writeln('    $action: $count');
    });
    buffer.writeln('  By type:');
    conflictsByType.forEach((type, count) {
      buffer.writeln('    $type: $count');
    });
    if (lastConflictAt != null) {
      buffer.writeln('  Last conflict: $lastConflictAt');
    }
    return buffer.toString();
  }
}
