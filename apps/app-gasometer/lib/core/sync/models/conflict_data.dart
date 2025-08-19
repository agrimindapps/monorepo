import '../../data/models/base_sync_model.dart';

/// Dados de conflito entre entidades local e remota
class ConflictData<T extends BaseSyncModel> {
  /// Entidade local
  final T localData;

  /// Entidade remota
  final T remoteData;

  /// Timestamp da última modificação local
  final DateTime localTimestamp;

  /// Timestamp da última modificação remota
  final DateTime remoteTimestamp;

  /// Tipo do modelo em conflito
  final String modelType;

  /// Campos específicos que estão em conflito
  final List<String> conflictingFields;

  /// Metadados adicionais sobre o conflito
  final Map<String, dynamic> metadata;

  /// ID do usuário que modificou localmente
  final String? localModifiedBy;

  /// ID do usuário que modificou remotamente
  final String? remoteModifiedBy;

  ConflictData({
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
    required this.modelType,
    this.conflictingFields = const [],
    this.metadata = const {},
    this.localModifiedBy,
    this.remoteModifiedBy,
  });

  /// Verifica se o conflito é baseado em tempo
  bool get isTemporalConflict {
    return localTimestamp != remoteTimestamp;
  }

  /// Verifica se o conflito é baseado em versão
  bool get isVersionConflict {
    return localData.version != remoteData.version;
  }

  /// Verifica se dados locais são mais recentes
  bool get isLocalNewer {
    return localTimestamp.isAfter(remoteTimestamp);
  }

  /// Verifica se dados remotos são mais recentes
  bool get isRemoteNewer {
    return remoteTimestamp.isAfter(localTimestamp);
  }

  /// Verifica se versão local é maior
  bool get isLocalVersionHigher {
    return localData.version > remoteData.version;
  }

  /// Verifica se versão remota é maior
  bool get isRemoteVersionHigher {
    return remoteData.version > localData.version;
  }

  /// Diferença em segundos entre os timestamps
  int get timestampDifferenceInSeconds {
    return localTimestamp.difference(remoteTimestamp).inSeconds.abs();
  }

  /// Diferença entre versões
  int get versionDifference {
    return (localData.version - remoteData.version).abs();
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'localTimestamp': localTimestamp.toIso8601String(),
      'remoteTimestamp': remoteTimestamp.toIso8601String(),
      'modelType': modelType,
      'conflictingFields': conflictingFields,
      'metadata': metadata,
      'localModifiedBy': localModifiedBy,
      'remoteModifiedBy': remoteModifiedBy,
      'localVersion': localData.version,
      'remoteVersion': remoteData.version,
      'isTemporalConflict': isTemporalConflict,
      'isVersionConflict': isVersionConflict,
    };
  }

  /// Cria instância a partir de dados básicos
  factory ConflictData.fromEntities(
    T localEntity,
    T remoteEntity, {
    List<String> conflictingFields = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return ConflictData<T>(
      localData: localEntity,
      remoteData: remoteEntity,
      localTimestamp: localEntity.updatedAt ?? localEntity.createdAt ?? DateTime.now(),
      remoteTimestamp: remoteEntity.updatedAt ?? remoteEntity.createdAt ?? DateTime.now(),
      modelType: localEntity.runtimeType.toString(),
      conflictingFields: conflictingFields,
      metadata: metadata,
      localModifiedBy: localEntity.userId,
      remoteModifiedBy: remoteEntity.userId,
    );
  }

  @override
  String toString() {
    return 'ConflictData<$modelType>(localTimestamp: $localTimestamp, '
           'remoteTimestamp: $remoteTimestamp, conflictingFields: $conflictingFields)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConflictData<T> &&
           other.localData.id == localData.id &&
           other.remoteData.id == remoteData.id &&
           other.modelType == modelType;
  }

  @override
  int get hashCode {
    return Object.hash(localData.id, remoteData.id, modelType);
  }
}