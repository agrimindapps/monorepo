import 'package:core/core.dart';
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
    return ComentarioHive(
      comentarioId: local.comentarioId,
      culturaId: local.culturaId ?? remote.culturaId,
      autorNome: local.autorNome ?? remote.autorNome,
      autorAvatar: local.autorAvatar ?? remote.autorAvatar,
      comentario: local.comentario.isNotEmpty ? local.comentario : remote.comentario,
      data: local.data ?? remote.data,
      isOffline: false, // Após merge, não é mais offline-only
    );
  }

  /// Merge específico para DiagnosticoHive
  DiagnosticoHive _mergeDiagnosticoModel(
    DiagnosticoHive local,
    DiagnosticoHive remote,
  ) {
    // Para diagnósticos, mesclamos informações preservando dados locais mais recentes
    return DiagnosticoHive(
      diagnosticoId: local.diagnosticoId,
      culturaId: local.culturaId ?? remote.culturaId,
      tituloReclamacao: local.tituloReclamacao.isNotEmpty
          ? local.tituloReclamacao
          : remote.tituloReclamacao,
      descricaoReclamacao: local.descricaoReclamacao.isNotEmpty
          ? local.descricaoReclamacao
          : remote.descricaoReclamacao,
      imagensReclamacao: local.imagensReclamacao.isNotEmpty
          ? local.imagensReclamacao
          : remote.imagensReclamacao,
      diagnostico: local.diagnostico ?? remote.diagnostico,
      recomendacao: local.recomendacao ?? remote.recomendacao,
      fitossanitariosRecomendados: local.fitossanitariosRecomendados.isNotEmpty
          ? local.fitossanitariosRecomendados
          : remote.fitossanitariosRecomendados,
      data: local.data ?? remote.data,
      processado: local.processado || remote.processado,
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
