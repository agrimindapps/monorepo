import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../features/comentarios/data/comentario_model.dart';
import '../../../features/comentarios/data/services/comentarios_sync_service.dart';
import '../../../features/comentarios/domain/comentarios_service.dart';
import '../../services/device_identity_service.dart';
import '../models/comentario_legacy.dart';

/// Repository for comentarios using Hive storage with type-safe boxes.
/// ✅ MIGRATED: Using `IHiveManager.getBox<T>()` para type safety com cast seguro
/// BENEFIT: Funciona com `Box<dynamic>` já aberta pelo BoxRegistryService
@LazySingleton()
class ComentariosLegacyRepository implements IComentariosRepository {
  final IHiveManager _hiveManager;
  final String boxName = 'comentarios';
  Box<ComentarioHive>? _box;

  // Sync service para sincronização com Firebase
  late final ComentariosSyncService _syncService;

  ComentariosLegacyRepository()
    : _hiveManager = GetIt.instance<IHiveManager>() {
    _syncService = ComentariosSyncService();
  }

  /// Obtém a box tipada `Box<ComentarioHive>` com safe cast
  /// Se a box já está aberta como `Box<dynamic>`, faz cast seguro
  Future<Box<ComentarioHive>> get box async {
    if (_box != null && _box!.isOpen) return _box!;

    final result = await _hiveManager.getBox<ComentarioHive>(boxName);
    return result.fold(
      (failure) =>
          throw Exception('Failed to open Hive box: ${failure.message}'),
      (typedBox) {
        _box = typedBox;
        return typedBox;
      },
    );
  }

  /// Implementação da interface IComentariosRepository
  @override
  Future<List<ComentarioModel>> getAllComentarios() async {
    try {
      final userId = await _getCurrentUserId();
      final hiveBox = await box;

      // ✅ box.values já é Iterable<ComentarioHive> (type-safe)
      final userComments =
          hiveBox.values
              .where((item) => !item.sync_deleted && item.userId == userId)
              .toList()
            ..sort((a, b) {
              final aTime = a.sync_createdAt ?? 0;
              final bTime = b.sync_createdAt ?? 0;
              return bTime.compareTo(aTime); // Mais recente primeiro
            });

      return userComments.map((hive) => hive.toComentarioModel()).toList();
    } catch (e) {
      throw Exception('Erro ao carregar comentários: $e');
    }
  }

  @override
  Future<void> addComentario(ComentarioModel comentario) async {
    try {
      final userId = await _getCurrentUserId();
      final hiveComentario = ComentarioHive.fromComentarioModel(
        comentario,
        userId,
      );
      if (hiveComentario.idReg.isEmpty) {
        hiveComentario.idReg = _generateId();
      }

      // 1. Salva localmente usando Box<dynamic>
      final hiveBox = await box;
      await hiveBox.put(hiveComentario.idReg, hiveComentario);

      if (kDebugMode) {
        debugPrint(
          '✅ [ComentariosRepository] Comentário salvo localmente: ${hiveComentario.idReg}',
        );
      }

      // 2. Sincroniza com Firebase (igual aos favoritos)
      try {
        // Atualiza o modelo com o ID gerado
        final comentarioComId = comentario.copyWith(
          idReg: hiveComentario.idReg,
        );
        await _syncService.syncOperation('create', comentarioComId);

        if (kDebugMode) {
          debugPrint(
            '✅ [ComentariosRepository] Comentário salvo e sincronizado: ${hiveComentario.idReg}',
          );
        }
      } catch (syncError) {
        // Sync falhou mas local está OK - não bloqueia a operação
        if (kDebugMode) {
          debugPrint(
            '⚠️ [ComentariosRepository] Erro na sincronização (local OK): $syncError',
          );
        }
      }
    } catch (e) {
      throw Exception('Erro ao adicionar comentário: $e');
    }
  }

  @override
  Future<void> updateComentario(ComentarioModel comentario) async {
    try {
      final userId = await _getCurrentUserId();
      final hiveBox = await box;

      // ✅ box.get() já retorna ComentarioHive? (type-safe)
      final existing = hiveBox.get(comentario.idReg);
      if (existing == null) {
        throw Exception('Comentário não encontrado');
      }
      if (existing.userId != userId) {
        throw Exception('Não autorizado a editar este comentário');
      }
      existing.conteudo = comentario.conteudo;
      existing.titulo = comentario.titulo;
      existing.sync_updatedAt = DateTime.now().millisecondsSinceEpoch;

      // 1. Salva localmente
      await existing.save();

      // 2. Sincroniza com Firebase
      try {
        await _syncService.syncOperation('update', comentario);
        if (kDebugMode) {
          debugPrint(
            '✅ [ComentariosRepository] Comentário atualizado e sincronizado: ${comentario.idReg}',
          );
        }
      } catch (syncError) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [ComentariosRepository] Erro na sincronização de update (local OK): $syncError',
          );
        }
      }
    } catch (e) {
      throw Exception('Erro ao atualizar comentário: $e');
    }
  }

  @override
  Future<void> deleteComentario(String id) async {
    try {
      final userId = await _getCurrentUserId();
      final hiveBox = await box;

      // ✅ box.get() já retorna ComentarioHive? (type-safe)
      final existing = hiveBox.get(id);
      if (existing == null) {
        throw Exception('Comentário não encontrado');
      }
      if (existing.userId != userId) {
        throw Exception('Não autorizado a deletar este comentário');
      }
      existing.sync_deleted = true;
      existing.sync_updatedAt = DateTime.now().millisecondsSinceEpoch;

      // 1. Marca como deletado localmente (soft delete)
      await existing.save();

      // 2. Sincroniza deleção com Firebase
      try {
        final comentarioModel = existing.toComentarioModel();
        await _syncService.syncOperation('delete', comentarioModel);
        if (kDebugMode) {
          debugPrint(
            '✅ [ComentariosRepository] Comentário deletado e sincronizado: $id',
          );
        }
      } catch (syncError) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [ComentariosRepository] Erro na sincronização de delete (local OK): $syncError',
          );
        }
      }
    } catch (e) {
      throw Exception('Erro ao deletar comentário: $e');
    }
  }

  /// Busca um comentário por ID
  Future<ComentarioModel?> getComentarioById(String id) async {
    try {
      final hiveBox = await box;
      final value = hiveBox.get(id);
      if (value == null) {
        return null;
      }

      final userId = await _getCurrentUserId();
      if (value.userId != userId) {
        return null;
      }
      if (value.sync_deleted) {
        return null; // Só retorna comentários ativos (não deletados)
      }

      return value.toComentarioModel();
    } catch (e) {
      throw Exception('Erro ao buscar comentário por ID: $e');
    }
  }

  /// Busca comentários por pkIdentificador (contexto específico)
  Future<List<ComentarioModel>> getComentariosByContext(
    String pkIdentificador,
  ) async {
    try {
      final userId = await _getCurrentUserId();
      final hiveBox = await box;

      // ✅ box.values já é Iterable<ComentarioHive> (type-safe)
      final contextComments =
          hiveBox.values
              .where(
                (item) =>
                    !item.sync_deleted &&
                    item.userId == userId &&
                    item.pkIdentificador == pkIdentificador,
              )
              .toList()
            ..sort((a, b) {
              final aTime = a.sync_createdAt ?? 0;
              final bTime = b.sync_createdAt ?? 0;
              return bTime.compareTo(aTime);
            });

      return contextComments.map((hive) => hive.toComentarioModel()).toList();
    } catch (e) {
      throw Exception('Erro ao carregar comentários por contexto: $e');
    }
  }

  /// Busca comentários por ferramenta
  Future<List<ComentarioModel>> getComentariosByTool(String ferramenta) async {
    try {
      final userId = await _getCurrentUserId();
      final hiveBox = await box;

      // ✅ box.values já é Iterable<ComentarioHive> (type-safe)
      final toolComments =
          hiveBox.values
              .where(
                (item) =>
                    !item.sync_deleted &&
                    item.userId == userId &&
                    item.ferramenta == ferramenta,
              )
              .toList()
            ..sort((a, b) {
              final aTime = a.sync_createdAt ?? 0;
              final bTime = b.sync_createdAt ?? 0;
              return bTime.compareTo(aTime);
            });

      return toolComments.map((hive) => hive.toComentarioModel()).toList();
    } catch (e) {
      throw Exception('Erro ao carregar comentários por ferramenta: $e');
    }
  }

  /// Limpa comentários antigos (mais de 90 dias inativos)
  Future<void> cleanupOldComments() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final cutoffTime = now - (90 * 24 * 60 * 60 * 1000); // 90 dias em ms

      final hiveBox = await box;

      // ✅ box.values já é Iterable<ComentarioHive> (type-safe)
      final oldInactiveComments = hiveBox.values
          .where(
            (item) =>
                item.sync_deleted && (item.sync_updatedAt ?? 0) < cutoffTime,
          )
          .toList();

      for (final comment in oldInactiveComments) {
        await comment.delete();
      }
    } catch (e) {
      throw Exception('Erro ao limpar comentários antigos: $e');
    }
  }

  /// Obtém estatísticas dos comentários do usuário
  Future<Map<String, int>> getUserCommentStats() async {
    try {
      final userId = await _getCurrentUserId();
      final hiveBox = await box;

      // ✅ box.values já é Iterable<ComentarioHive> (type-safe)
      final userComments = hiveBox.values
          .where((ComentarioHive item) => item.userId == userId)
          .toList();

      final activeComments = userComments
          .where((ComentarioHive item) => !item.sync_deleted)
          .length;
      final deletedComments = userComments
          .where((ComentarioHive item) => item.sync_deleted)
          .length;
      final toolCounts = <String, int>{};
      for (final comment in userComments.where(
        (ComentarioHive item) => !item.sync_deleted,
      )) {
        toolCounts[comment.ferramenta] =
            (toolCounts[comment.ferramenta] ?? 0) + 1;
      }

      return {
        'total': userComments.length,
        'active': activeComments,
        'deleted': deletedComments,
        'tools': toolCounts.length,
        ...toolCounts,
      };
    } catch (e) {
      return {'error': 1};
    }
  }

  /// Obtém ID do usuário atual
  /// Para usuários autenticados, usa Firebase UID
  /// Para usuários não autenticados, usa UUID único do dispositivo
  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return await DeviceIdentityService.instance.getDeviceUuid();
    }
    return user.uid;
  }

  /// Gera ID único para comentário
  String _generateId() {
    return 'COMM_${DateTime.now().millisecondsSinceEpoch}';
  }
}
