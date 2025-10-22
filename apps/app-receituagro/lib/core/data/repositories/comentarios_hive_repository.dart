import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../features/comentarios/data/comentario_model.dart';
import '../../../features/comentarios/data/services/comentarios_sync_service.dart';
import '../../../features/comentarios/domain/comentarios_service.dart';
import '../../services/device_identity_service.dart';
import '../models/comentario_hive.dart';

class ComentariosHiveRepository extends BaseHiveRepository<ComentarioHive>
    implements IComentariosRepository {
  // Sync service para sincronização com Firebase
  late final ComentariosSyncService _syncService;

  ComentariosHiveRepository() : super(
    hiveManager: GetIt.instance<IHiveManager>(),
    boxName: 'comentarios',
  ) {
    _syncService = ComentariosSyncService();
  }

  /// Implementação da interface IComentariosRepository
  @override
  Future<List<ComentarioModel>> getAllComentarios() async {
    try {
      final userId = await _getCurrentUserId();
      final result = await getAll();
      
      if (result.isError) {
        throw Exception('Erro ao acessar dados: ${result.error}');
      }
      
      final hiveitems = result.data!;
      final userComments = hiveitems
          .where((item) => item.status && item.userId == userId)
          .toList()
        ..sort((a, b) {
          final aTime = a.createdAt ?? 0;
          final bTime = b.createdAt ?? 0;
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
      final hiveComentario = ComentarioHive.fromComentarioModel(comentario, userId);
      if (hiveComentario.idReg.isEmpty) {
        hiveComentario.idReg = _generateId();
      }

      // 1. Salva localmente usando BaseHiveRepository
      final result = await save(hiveComentario, key: hiveComentario.idReg);
      if (result.isError) {
        throw Exception('Erro ao salvar: ${result.error}');
      }

      // 2. Sincroniza com Firebase (igual aos favoritos)
      try {
        // Atualiza o modelo com o ID gerado
        final comentarioComId = comentario.copyWith(idReg: hiveComentario.idReg);
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
      final result = await getByKey(comentario.idReg);
      if (result.isError) {
        throw Exception('Erro ao acessar comentário: ${result.error}');
      }

      final existing = result.data;
      if (existing == null) {
        throw Exception('Comentário não encontrado');
      }
      if (existing.userId != userId) {
        throw Exception('Não autorizado a editar este comentário');
      }
      existing.conteudo = comentario.conteudo;
      existing.titulo = comentario.titulo;
      existing.updatedAt = DateTime.now().millisecondsSinceEpoch;

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
      final result = await getByKey(id);
      if (result.isError) {
        throw Exception('Erro ao acessar comentário: ${result.error}');
      }

      final existing = result.data;
      if (existing == null) {
        throw Exception('Comentário não encontrado');
      }
      if (existing.userId != userId) {
        throw Exception('Não autorizado a deletar este comentário');
      }
      existing.status = false;
      existing.updatedAt = DateTime.now().millisecondsSinceEpoch;

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

  /// Busca comentários por pkIdentificador (contexto específico)
  Future<List<ComentarioModel>> getComentariosByContext(String pkIdentificador) async {
    try {
      final userId = await _getCurrentUserId();
      final result = await getAll();
      if (result.isError) {
        throw Exception('Erro ao acessar dados: ${result.error}');
      }
      final hiveitems = result.data!;
      
      final contextComments = hiveitems
          .where((item) => 
              item.status && 
              item.userId == userId && 
              item.pkIdentificador == pkIdentificador)
          .toList()
        ..sort((a, b) {
          final aTime = a.createdAt ?? 0;
          final bTime = b.createdAt ?? 0;
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
      final result = await getAll();
      if (result.isError) {
        throw Exception('Erro ao acessar dados: ${result.error}');
      }
      final hiveitems = result.data!;
      
      final toolComments = hiveitems
          .where((item) => 
              item.status && 
              item.userId == userId && 
              item.ferramenta == ferramenta)
          .toList()
        ..sort((a, b) {
          final aTime = a.createdAt ?? 0;
          final bTime = b.createdAt ?? 0;
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
      
      final result = await getAll();
      if (result.isError) {
        throw Exception('Erro ao acessar dados: ${result.error}');
      }
      final hiveitems = result.data!;
      final oldInactiveComments = hiveitems
          .where((item) => 
              !item.status && 
              (item.updatedAt ?? 0) < cutoffTime)
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
      final result = await getAll();
      if (result.isError) {
        throw Exception('Erro ao acessar dados: ${result.error}');
      }
      final hiveitems = result.data!;
      
      final userComments = hiveitems
          .where((item) => item.userId == userId)
          .toList();

      final activeComments = userComments.where((item) => item.status).length;
      final deletedComments = userComments.where((item) => !item.status).length;
      final toolCounts = <String, int>{};
      for (final comment in userComments.where((item) => item.status)) {
        toolCounts[comment.ferramenta] = (toolCounts[comment.ferramenta] ?? 0) + 1;
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
