import 'dart:developer' as developer;

import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../../domain/entities/comentario_sync_entity.dart';
import '../comentario_model.dart';

/// Service especializado para sincronização de comentários com Firebase
/// Responsabilidade: Sincronizar operações de comentários com Firestore
///
/// Segue o mesmo padrão do FavoritosSyncService
class ComentariosSyncService {
  ComentariosSyncService();

  /// Sincroniza uma operação de comentário com Firestore
  ///
  /// [operation] - 'create', 'update' ou 'delete'
  /// [comentario] - Modelo do comentário a ser sincronizado
  Future<void> syncOperation(
    String operation,
    ComentarioModel comentario,
  ) async {
    if (kDebugMode) {
      developer.log(
        'Sincronizando $operation: id=${comentario.idReg}',
        name: 'ComentariosSync',
      );
    }

    try {
      // Valida autenticação
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'Usuário não autenticado - sync cancelado',
            name: 'ComentariosSync',
          );
        }
        return;
      }

      // Valida dados
      if (comentario.idReg.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'Dados inválidos - sync cancelado',
            name: 'ComentariosSync',
          );
        }
        return;
      }

      // Cria entidade de sincronização
      final syncEntity = ComentarioSyncEntity(
        id: 'comment_${comentario.idReg}',
        idReg: comentario.idReg,
        titulo: comentario.titulo,
        conteudo: comentario.conteudo,
        ferramenta: comentario.ferramenta,
        pkIdentificador: comentario.pkIdentificador,
        status: comentario.status,
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
          name: 'ComentariosSync',
          error: e,
        );
      }
    }
  }

  /// Executa a operação de sincronização com Firestore
  Future<void> _executeSyncOperation(
    String operation,
    ComentarioSyncEntity syncEntity,
  ) async {
    try {
      if (operation == 'create') {
        final result = await core.UnifiedSyncManager.instance
            .create<ComentarioSyncEntity>('receituagro', syncEntity);

        result.fold(
          (core.Failure failure) {
            if (kDebugMode) {
              developer.log(
                'Erro no create: ${failure.message}',
                name: 'ComentariosSync',
              );
            }
          },
          (String entityId) {
            if (kDebugMode) {
              developer.log(
                'Create bem-sucedido: $entityId',
                name: 'ComentariosSync',
              );
            }
          },
        );
      } else if (operation == 'update') {
        final result = await core.UnifiedSyncManager.instance
            .update<ComentarioSyncEntity>('receituagro', syncEntity.id, syncEntity);

        result.fold(
          (core.Failure failure) {
            if (kDebugMode) {
              developer.log(
                'Erro no update: ${failure.message}',
                name: 'ComentariosSync',
              );
            }
          },
          (_) {
            if (kDebugMode) {
              developer.log(
                'Update bem-sucedido',
                name: 'ComentariosSync',
              );
            }
          },
        );
      } else if (operation == 'delete') {
        final result = await core.UnifiedSyncManager.instance
            .delete<ComentarioSyncEntity>('receituagro', syncEntity.id);

        result.fold(
          (core.Failure failure) {
            if (kDebugMode) {
              developer.log(
                'Erro no delete: ${failure.message}',
                name: 'ComentariosSync',
              );
            }
          },
          (_) {
            if (kDebugMode) {
              developer.log(
                'Delete bem-sucedido',
                name: 'ComentariosSync',
              );
            }
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Erro executando operação $operation: $e',
          name: 'ComentariosSync',
          error: e,
        );
      }
      // Não propaga erro para não bloquear operação local
    }
  }
}
