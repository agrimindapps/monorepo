import 'base_entity.dart';

/// Entidade base para sincronização com Firebase
/// Estende BaseEntity com campos específicos para operações offline-first
abstract class BaseSyncEntity extends BaseEntity {
  const BaseSyncEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    this.lastSyncAt,
    this.isDirty = false,
    this.isDeleted = false,
    this.version = 1,
    this.userId,
    this.moduleName,
  });

  /// Último timestamp de sincronização com Firebase
  final DateTime? lastSyncAt;

  /// Se tem mudanças locais não sincronizadas
  final bool isDirty;

  /// Se foi marcado para exclusão (soft delete)
  final bool isDeleted;

  /// Versão do documento para controle de conflitos
  final int version;

  /// ID do usuário proprietário (para particionamento no Firebase)
  final String? userId;

  /// Nome do módulo/app que criou/modificou
  final String? moduleName;

  /// Se precisa ser sincronizado
  bool get needsSync => isDirty || lastSyncAt == null;

  /// Se é um item apenas local (nunca foi sincronizado)
  bool get isLocalOnly => lastSyncAt == null;

  /// Tempo desde a última sincronização
  Duration? get timeSinceLastSync {
    if (lastSyncAt == null) return null;
    return DateTime.now().difference(lastSyncAt!);
  }

  /// Converte para Map para Firebase
  Map<String, dynamic> toFirebaseMap();

  /// Cria instância do Map do Firebase
  /// Deve ser implementado por cada subclasse

  /// Marca como "sujo" (precisa sincronizar)
  BaseSyncEntity markAsDirty();

  /// Marca como sincronizado
  BaseSyncEntity markAsSynced({DateTime? syncTime});

  /// Marca como deletado (soft delete)
  BaseSyncEntity markAsDeleted();

  /// Incrementa versão (para controle de conflitos)
  BaseSyncEntity incrementVersion();

  /// Define usuário proprietário
  BaseSyncEntity withUserId(String userId);

  /// Define módulo/app
  BaseSyncEntity withModule(String moduleName);

  @override
  BaseSyncEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  });

  /// Verifica se pode ser mesclado com outra versão
  bool canMergeWith(BaseSyncEntity other) {
    return id == other.id && !isDeleted && !other.isDeleted;
  }

  /// Resolve conflito entre duas versões
  /// Por padrão, usa timestamp mais recente
  BaseSyncEntity resolveConflictWith(BaseSyncEntity other) {
    if (isDeleted || other.isDeleted) {
      return isDeleted ? this : other;
    }
    if (version != other.version) {
      return version > other.version ? this : other;
    }
    final thisUpdate =
        updatedAt ?? createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final otherUpdate =
        other.updatedAt ??
        other.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return thisUpdate.isAfter(otherUpdate) ? this : other;
  }

  /// Campos base para toFirebaseMap
  Map<String, dynamic> get baseFirebaseFields => {
    'id': id,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'last_sync_at': lastSyncAt?.toIso8601String(),
    'is_dirty': isDirty,
    'is_deleted': isDeleted,
    'version': version,
    'user_id': userId,
    'module_name': moduleName,
  };

  /// Campos base para fromFirebaseMap
  static Map<String, dynamic> parseBaseFirebaseFields(
    Map<String, dynamic> map,
  ) {
    return {
      'id': map['id'] as String?,
      'createdAt':
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null,
      'updatedAt':
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'] as String)
              : null,
      'lastSyncAt':
          map['last_sync_at'] != null
              ? DateTime.parse(map['last_sync_at'] as String)
              : null,
      'isDirty': map['is_dirty'] as bool? ?? false,
      'isDeleted': map['is_deleted'] as bool? ?? false,
      'version': map['version'] as int? ?? 1,
      'userId': map['user_id'] as String?,
      'moduleName': map['module_name'] as String?,
    };
  }

  @override
  List<Object?> get props => [
    ...super.props,
    lastSyncAt,
    isDirty,
    isDeleted,
    version,
    userId,
    moduleName,
  ];
}

/// Mixin para funcionalidades de sincronização
mixin SyncEntityMixin {
  /// Gera timestamp de sincronização
  DateTime generateSyncTimestamp() => DateTime.now();

  /// Calcula hash para detecção de mudanças
  String calculateContentHash(Map<String, dynamic> content) {
    final sorted = Map.fromEntries(
      content.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted.toString().hashCode.toString();
  }

  /// Valida se os dados estão consistentes para sincronização
  bool validateForSync(BaseSyncEntity entity) {
    if (entity.id.isEmpty) return false;
    if (entity.isDeleted && entity.version <= 0) return false;
    if (entity.userId?.isEmpty == true) return false;
    return true;
  }

  /// Prepara dados para batch sync
  Map<String, dynamic> prepareBatchData(List<BaseSyncEntity> entities) {
    final creates = <Map<String, dynamic>>[];
    final updates = <Map<String, dynamic>>[];
    final deletes = <String>[];

    for (final entity in entities) {
      if (!validateForSync(entity)) continue;

      if (entity.isDeleted) {
        deletes.add(entity.id);
      } else if (entity.isLocalOnly) {
        creates.add(entity.toFirebaseMap());
      } else {
        updates.add(entity.toFirebaseMap());
      }
    }

    return {
      'creates': creates,
      'updates': updates,
      'deletes': deletes,
      'timestamp': generateSyncTimestamp().toIso8601String(),
    };
  }
}

/// Status de sincronização para uma entidade
enum SyncEntityStatus {
  /// Sincronizado com sucesso
  synced,

  /// Pendente de sincronização
  pending,

  /// Erro na sincronização
  error,

  /// Conflito detectado
  conflict,

  /// Apenas local (nunca sincronizado)
  localOnly,

  /// Marcado para exclusão
  markedForDeletion,
}

/// Extensão para facilitar o uso do status
extension SyncEntityStatusExtension on SyncEntityStatus {
  bool get isSuccessful => this == SyncEntityStatus.synced;
  bool get needsAction => [
    SyncEntityStatus.pending,
    SyncEntityStatus.error,
    SyncEntityStatus.conflict,
  ].contains(this);
  bool get canDelete =>
      [SyncEntityStatus.synced, SyncEntityStatus.localOnly].contains(this);
}

/// Resultado de operação de sincronização
class SyncResult<T extends BaseSyncEntity> {
  const SyncResult({
    required this.status,
    this.entity,
    this.error,
    this.conflictEntity,
    this.attempts = 1,
    this.lastAttempt,
  });

  final SyncEntityStatus status;
  final T? entity;
  final String? error;
  final T? conflictEntity;
  final int attempts;
  final DateTime? lastAttempt;

  bool get isSuccess => status.isSuccessful;
  bool get hasError => error != null;
  bool get hasConflict => conflictEntity != null;

  SyncResult<T> copyWith({
    SyncEntityStatus? status,
    T? entity,
    String? error,
    T? conflictEntity,
    int? attempts,
    DateTime? lastAttempt,
  }) {
    return SyncResult<T>(
      status: status ?? this.status,
      entity: entity ?? this.entity,
      error: error ?? this.error,
      conflictEntity: conflictEntity ?? this.conflictEntity,
      attempts: attempts ?? this.attempts,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
  }

  @override
  String toString() {
    return 'SyncResult(status: $status, hasEntity: ${entity != null}, '
        'hasError: $hasError, hasConflict: $hasConflict, attempts: $attempts)';
  }
}
