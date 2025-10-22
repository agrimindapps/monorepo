import 'package:core/core.dart' hide ConflictResolutionStrategy;
import '../data/models/base_sync_model.dart';
import '../data/models/comentario_hive.dart';
import '../data/models/diagnostico_hive.dart';
import 'conflict_resolution_strategy.dart';

@injectable
class ConflictResolver {
  /// Resolve conflito baseado na estratégia definida
  dynamic resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return conflictData.localData;
      case ConflictResolutionStrategy.remoteWins:
        return conflictData.remoteData;
      case ConflictResolutionStrategy.newerWins:
        return _resolveNewerWins(conflictData);
      case ConflictResolutionStrategy.merge:
        return _mergeData(conflictData);
      case ConflictResolutionStrategy.manual:
        throw UnimplementedError('Resolução manual ainda não implementada');
    }
  }

  /// Resolve conflito escolhendo o dado mais recente
  dynamic _resolveNewerWins(ConflictData conflictData) {
    return conflictData.isLocalNewer
        ? conflictData.localData
        : conflictData.remoteData;
  }

  /// Merge inteligente baseado no tipo de modelo
  dynamic _mergeData(ConflictData conflictData) {
    switch (conflictData.modelType) {
      case 'ComentarioHive':
        return _mergeComentarioModel(
          conflictData.localData as ComentarioHive,
          conflictData.remoteData as ComentarioHive,
        );
      case 'DiagnosticoHive':
        return _mergeDiagnosticoModel(
          conflictData.localData as DiagnosticoHive,
          conflictData.remoteData as DiagnosticoHive,
        );
      default:
        // Para tipos não implementados, usa newerWins
        return _resolveNewerWins(conflictData);
    }
  }

  /// Merge específico para ComentarioHive
  ComentarioHive _mergeComentarioModel(
    ComentarioHive local,
    ComentarioHive remote,
  ) {
    // Para comentários, preferimos local se foi editado mais recentemente
    // mas preservamos informações importantes do remote
    final isLocalNewer = (local.updatedAt ?? 0) >= (remote.updatedAt ?? 0);

    return ComentarioHive(
      objectId: local.objectId ?? remote.objectId,
      createdAt: local.createdAt ?? remote.createdAt,
      updatedAt: isLocalNewer ? local.updatedAt : remote.updatedAt,
      idReg: local.idReg,
      status: isLocalNewer ? local.status : remote.status,
      titulo: isLocalNewer && local.titulo.isNotEmpty ? local.titulo : remote.titulo,
      conteudo: isLocalNewer && local.conteudo.isNotEmpty ? local.conteudo : remote.conteudo,
      ferramenta: local.ferramenta.isNotEmpty ? local.ferramenta : remote.ferramenta,
      pkIdentificador: local.pkIdentificador,
      userId: local.userId.isNotEmpty ? local.userId : remote.userId,
    );
  }

  /// Merge específico para DiagnosticoHive
  DiagnosticoHive _mergeDiagnosticoModel(
    DiagnosticoHive local,
    DiagnosticoHive remote,
  ) {
    // Para diagnósticos, mesclamos informações preservando dados locais mais recentes
    final isLocalNewer = local.updatedAt >= remote.updatedAt;

    return DiagnosticoHive(
      objectId: local.objectId,
      createdAt: local.createdAt,
      updatedAt: isLocalNewer ? local.updatedAt : remote.updatedAt,
      idReg: local.idReg,
      fkIdDefensivo: isLocalNewer ? local.fkIdDefensivo : remote.fkIdDefensivo,
      nomeDefensivo: local.nomeDefensivo ?? remote.nomeDefensivo,
      fkIdCultura: isLocalNewer ? local.fkIdCultura : remote.fkIdCultura,
      nomeCultura: local.nomeCultura ?? remote.nomeCultura,
      fkIdPraga: isLocalNewer ? local.fkIdPraga : remote.fkIdPraga,
      nomePraga: local.nomePraga ?? remote.nomePraga,
      dsMin: local.dsMin ?? remote.dsMin,
      dsMax: isLocalNewer ? local.dsMax : remote.dsMax,
      um: isLocalNewer ? local.um : remote.um,
      minAplicacaoT: local.minAplicacaoT ?? remote.minAplicacaoT,
      maxAplicacaoT: local.maxAplicacaoT ?? remote.maxAplicacaoT,
      umT: local.umT ?? remote.umT,
      minAplicacaoA: local.minAplicacaoA ?? remote.minAplicacaoA,
      maxAplicacaoA: local.maxAplicacaoA ?? remote.maxAplicacaoA,
      umA: local.umA ?? remote.umA,
      intervalo: local.intervalo ?? remote.intervalo,
      intervalo2: local.intervalo2 ?? remote.intervalo2,
      epocaAplicacao: local.epocaAplicacao ?? remote.epocaAplicacao,
    );
  }

  /// Generic merge for BaseSyncModel entities
  T mergeBaseSyncModel<T extends BaseSyncModel>(T local, T remote) {
    final DateTime now = DateTime.now();

    // Use copyWith if available, otherwise return newer version
    if (local.updatedAt != null && remote.updatedAt != null) {
      if (local.updatedAt!.isAfter(remote.updatedAt!)) {
        return local.copyWith(
          lastSyncAt: now,
          isDirty: false,
          version: local.version > remote.version ? local.version : remote.version + 1,
        ) as T;
      } else {
        return remote.copyWith(
          lastSyncAt: now,
          isDirty: false,
          version: remote.version > local.version ? remote.version : local.version + 1,
        ) as T;
      }
    }

    // Fallback: return local if no timestamps
    return local;
  }
}
