import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'favoritos_data_resolver_service.dart';

/// Service especializado para sincronização de favoritos com Firebase
///
/// ⚠️ REFACTOR: Esta classe foi simplificada para NÃO realizar chamadas de API diretas.
/// A responsabilidade de sincronização agora é do [SyncCoordinator] e [FavoritosDriftSyncAdapter].
///
/// Esta classe agora serve apenas como um utilitário para resolver dados antes de salvar no banco local,
/// se necessário, ou pode ser depreciada futuramente.
@injectable
class FavoritosSyncService {
  final FavoritosDataResolverService _dataResolver;

  FavoritosSyncService({required FavoritosDataResolverService dataResolver})
    : _dataResolver = dataResolver;

  /// Prepara dados para salvamento local (Drift)
  ///
  /// Não realiza mais chamadas ao Firestore. O Drift se encarrega de marcar como dirty
  /// e o SyncWorker fará o envio em background.
  Future<Map<String, dynamic>?> prepareDataForLocalSave(
    String tipo,
    String id,
    Map<String, dynamic>? data,
  ) async {
    if (kDebugMode) {
      developer.log(
        'Preparando dados para save local: tipo=$tipo, id=$id',
        name: 'FavoritosSync',
      );
    }

    try {
      // Resolve dados se necessário
      final resolvedData =
          data ?? await _dataResolver.resolveItemData(tipo, id);
      if (resolvedData == null) {
        if (kDebugMode) {
          developer.log(
            'Não foi possível resolver dados para cache local',
            name: 'FavoritosSync',
          );
        }
        return null;
      }
      return resolvedData;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao preparar dados: $e',
          name: 'FavoritosSync',
          error: e,
        );
      }
      return null;
    }
  }

  /// @Deprecated("Deprecated - use alternative") Use prepareDataForLocalSave e salve no repositório Drift
  Future<void> syncOperation(
    String operation,
    String tipo,
    String id,
    Map<String, dynamic>? data,
  ) async {
    developer.log(
      'DEPRECATED: syncOperation chamado. O sistema agora usa Offline-First via Drift.',
      name: 'FavoritosSync',
    );
    // No-op: A sincronização real acontece via DriftSyncAdapter
  }
}
