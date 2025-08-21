/// Estratégias para resolução de conflitos durante sincronização
enum ConflictResolutionStrategy {
  /// Sempre mantém dados locais
  localWins,

  /// Sempre mantém dados remotos
  remoteWins,

  /// Mantém a versão mais recente baseada em timestamp
  newerWins,

  /// Abre interface para resolução manual
  manual,

  /// Tenta fazer merge automático inteligente
  merge,
}

/// Representa um conflito detectado durante sincronização
class ConflictData {
  final dynamic localData;
  final dynamic remoteData;
  final String modelType;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;

  ConflictData({
    required this.localData,
    required this.remoteData,
    required this.modelType,
    required this.localTimestamp,
    required this.remoteTimestamp,
  });
}
