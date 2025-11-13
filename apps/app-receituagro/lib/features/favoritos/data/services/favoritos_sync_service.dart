import 'dart:developer' as developer;

import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/favorito_sync_entity.dart';
import 'favoritos_data_resolver_service.dart';

/// Service especializado para sincronização de favoritos com Firebase
/// Responsabilidade: Sincronizar operações de favoritos com Firestore
@injectable
class FavoritosSyncService {
  final FavoritosDataResolverService _dataResolver;

  FavoritosSyncService({
    required FavoritosDataResolverService dataResolver,
  }) : _dataResolver = dataResolver;

  /// Sincroniza uma operação de favorito com Firestore
  ///
  /// Consolidado: Reduz logs de 15+ para 3-4 por operação
  ///
  /// [operation] - 'create', 'update' ou 'delete'
  /// [tipo] - Tipo do favorito (defensivo, praga, diagnostico, cultura)
  /// [id] - ID do item favorito
  /// [data] - Dados do item (opcional, será resolvido se null)
  Future<void> syncOperation(
    String operation,
    String tipo,
    String id,
    Map<String, dynamic>? data,
  ) async {
    if (kDebugMode) {
      developer.log(
        'Sincronizando $operation: tipo=$tipo, id=$id',
        name: 'FavoritosSync',
      );
    }

    try {
      // Valida autenticação
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'Usuário não autenticado - sync cancelado',
            name: 'FavoritosSync',
          );
        }
        return;
      }

      // Valida dados
      if (id.isEmpty || tipo.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'Dados inválidos - sync cancelado',
            name: 'FavoritosSync',
          );
        }
        return;
      }

      // Resolve dados se necessário
      final resolvedData = data ?? await _dataResolver.resolveItemData(tipo, id);
      if (resolvedData == null) {
        if (kDebugMode) {
          developer.log(
            'Não foi possível resolver dados - sync cancelado',
            name: 'FavoritosSync',
          );
        }
        return;
      }

      // Cria entidade de sincronização
      final syncEntity = FavoritoSyncEntity(
        id: 'favorite_${tipo}_$id',
        tipo: tipo,
        itemId: id,
        itemData: resolvedData,
        adicionadoEm: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: userId,
      );

      // Executa operação
      await _executeSyncOperation(operation, syncEntity);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro na sincronização: $e',
          name: 'FavoritosSync',
          error: e,
        );
      }
    }
  }

  /// Executa a operação de sincronização com Firestore
  Future<void> _executeSyncOperation(
    String operation,
    FavoritoSyncEntity syncEntity,
  ) async {
    try {
      if (operation == 'create') {
        final result = await core.UnifiedSyncManager.instance
            .create<FavoritoSyncEntity>('receituagro', syncEntity);

        result.fold(
          (core.Failure failure) {
            if (kDebugMode) {
              developer.log(
                'Erro no create: ${failure.message}',
                name: 'FavoritosSync',
              );
            }
          },
          (String entityId) {
            if (kDebugMode) {
              developer.log(
                'Create bem-sucedido: $entityId',
                name: 'FavoritosSync',
              );
            }
          },
        );
      } else if (operation == 'delete') {
        final result = await core.UnifiedSyncManager.instance
            .delete<FavoritoSyncEntity>('receituagro', syncEntity.id);

        result.fold(
          (core.Failure failure) {
            if (kDebugMode) {
              developer.log(
                'Erro no delete: ${failure.message}',
                name: 'FavoritosSync',
              );
            }
          },
          (_) {
            if (kDebugMode) {
              developer.log(
                'Delete bem-sucedido',
                name: 'FavoritosSync',
              );
            }
          },
        );
      } else {
        // update
        final result = await core.UnifiedSyncManager.instance
            .update<FavoritoSyncEntity>(
          'receituagro',
          syncEntity.id,
          syncEntity,
        );

        result.fold(
          (core.Failure failure) {
            if (kDebugMode) {
              developer.log(
                'Erro no update: ${failure.message}',
                name: 'FavoritosSync',
              );
            }
          },
          (_) {
            if (kDebugMode) {
              developer.log(
                'Update bem-sucedido',
                name: 'FavoritosSync',
              );
            }
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro ao executar operação: $e',
          name: 'FavoritosSync',
          error: e,
        );
      }
    }
  }
}
