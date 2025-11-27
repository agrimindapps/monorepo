import 'dart:developer' as developer;

import 'package:core/core.dart' as core;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/interfaces/i_premium_service.dart';
import '../../../features/comentarios/data/comentario_model.dart';
import '../constants/comentarios_design_tokens.dart';
import '../data/services/comentarios_mapper.dart';
import '../domain/entities/comentario_sync_entity.dart';
import 'repositories/i_comentarios_repository.dart';

/// Comentarios Service - Business Logic Layer
/// Does not manage state (no ChangeNotifier/Riverpod), just business operations
class ComentariosService {
  final IComentariosRepository? _repository;
  final IPremiumService? _premiumService;
  final IComentariosMapper? _mapper;

  ComentariosService({
    IComentariosRepository? repository,
    IPremiumService? premiumService,
    IComentariosMapper? mapper,
  })  : _repository = repository,
        _premiumService = premiumService,
        _mapper = mapper;

  Future<List<ComentarioModel>> getAllComentarios({
    String? pkIdentificador,
  }) async {
    try {
      final repository = _repository;
      final mapper = _mapper;
      if (repository == null || mapper == null) return [];

      final entities = pkIdentificador != null && pkIdentificador.isNotEmpty
          ? await repository.getComentariosByContext(pkIdentificador)
          : await repository.getAllComentarios();

      // Sort by createdAt descending
      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return mapper.entitiesToModels(entities);
    } catch (e) {
      return [];
    }
  }

  Future<void> addComentario(ComentarioModel comentario) async {
    developer.log(
      'Adicionando comentário - id=${comentario.id}, titulo="${comentario.titulo}"',
      name: 'ComentarioService',
      level: 500,
    );
    try {
      final repository = _repository;
      final mapper = _mapper;
      if (repository == null || mapper == null) return;

      developer.log('Salvando no repositório local',
          name: 'ComentarioService', level: 500);
      final entity = mapper.modelToEntity(comentario);
      await repository.addComentario(entity);

      developer.log('Comentário salvo localmente com sucesso',
          name: 'ComentarioService', level: 500);
      developer.log('Iniciando sincronização',
          name: 'ComentarioService', level: 500);
      await _queueSyncOperation('create', comentario);
    } catch (e) {
      developer.log('Error adding comentario',
          name: 'ComentarioService', error: e, level: 1000);
      rethrow;
    }
  }

  Future<void> updateComentario(ComentarioModel comentario) async {
    developer.log(
      'Atualizando comentário - id=${comentario.id}, titulo="${comentario.titulo}"',
      name: 'ComentarioService',
      level: 500,
    );
    try {
      final repository = _repository;
      final mapper = _mapper;
      if (repository == null || mapper == null) return;

      developer.log('Atualizando no repositório local',
          name: 'ComentarioService', level: 500);
      final entity = mapper.modelToEntity(comentario);
      await repository.updateComentario(entity);

      developer.log('Comentário atualizado localmente com sucesso',
          name: 'ComentarioService', level: 500);
      developer.log('Iniciando sincronização',
          name: 'ComentarioService', level: 500);
      await _queueSyncOperation('update', comentario);
    } catch (e) {
      developer.log('Error updating comentario',
          name: 'ComentarioService', error: e, level: 1000);
      rethrow;
    }
  }

  Future<void> deleteComentario(String id) async {
    developer.log('Deletando comentário - id=$id',
        name: 'ComentarioService', level: 500);
    try {
      final repository = _repository;
      if (repository == null) return;

      developer.log('Removendo do repositório local',
          name: 'ComentarioService', level: 500);
      await repository.deleteComentario(id);

      developer.log('Comentário removido localmente com sucesso',
          name: 'ComentarioService', level: 500);
      developer.log('Iniciando sincronização de deleção',
          name: 'ComentarioService', level: 500);

      await _queueSyncOperation(
        'delete',
        ComentarioModel(
          id: id,
          idReg: '',
          titulo: '',
          conteudo: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ferramenta: '',
          pkIdentificador: '',
          status: false,
        ),
      );
    } catch (e) {
      developer.log('Error deleting comentario',
          name: 'ComentarioService', error: e, level: 1000);
      rethrow;
    }
  }

  List<ComentarioModel> filterComentarios(
    List<ComentarioModel> comentarios,
    String searchText, {
    String? pkIdentificador,
    String? ferramenta,
  }) {
    if (comentarios.isEmpty) return comentarios;

    return comentarios.where((comentario) {
      if (searchText.isNotEmpty) {
        final searchLower = _sanitizeSearchText(searchText);
        final contentMatch = comentario.conteudo.toLowerCase().contains(
              searchLower,
            );
        final toolMatch = comentario.ferramenta.toLowerCase().contains(
              searchLower,
            );

        if (!contentMatch && !toolMatch) return false;
      }
      if (pkIdentificador != null &&
          pkIdentificador.isNotEmpty &&
          comentario.pkIdentificador != pkIdentificador) {
        return false;
      }

      if (ferramenta != null &&
          ferramenta.isNotEmpty &&
          comentario.ferramenta != ferramenta) {
        return false;
      }

      return true;
    }).toList();
  }

  String _sanitizeSearchText(String text) {
    if (text.length > ComentariosDesignTokens.maxSearchLength) {
      text = text.substring(0, ComentariosDesignTokens.maxSearchLength);
    }
    return text.toLowerCase().replaceAll(RegExp(r'[\\\[\]{}()*+?.^$|]'), '');
  }

  int getMaxComentarios() {
    return ComentariosDesignTokens.freeTierMaxComments;
  }

  bool canAddComentario(int currentCount) {
    final maxComentarios = getMaxComentarios();
    return currentCount < maxComentarios;
  }

  bool hasAdvancedFeatures() {
    return true;
  }

  bool isPremiumUser() {
    return _premiumService?.isPremium ?? false;
  }

  bool canUseComments() {
    return isPremiumUser();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String generateIdReg() {
    return 'REG_${DateTime.now().millisecondsSinceEpoch}';
  }

  bool isValidContent(String content) {
    return content.trim().length >= ComentariosDesignTokens.minCommentLength;
  }

  String getValidationErrorMessage() {
    return ComentariosDesignTokens.shortCommentError;
  }

  /// Sincroniza comentário usando sistema core
  Future<void> _queueSyncOperation(
    String operation,
    ComentarioModel comentario,
  ) async {
    developer.log(
      'Iniciando operação de sync - operation=$operation, comentario_id=${comentario.id}',
      name: 'ComentarioService',
      level: 500,
    );
    try {
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        developer.log(
          'Usuário não autenticado - pulando sincronização de comentário',
          name: 'ComentarioService',
          level: 900,
        );
        return;
      }

      developer.log(
        'Usuário autenticado - userId=$userId',
        name: 'ComentarioService',
        level: 500,
      );
      if (comentario.id.isEmpty) {
        developer.log(
          'ID do comentário inválido - pulando sincronização',
          name: 'ComentarioService',
          level: 1000,
        );
        return;
      }

      developer.log(
        'Dados do comentário válidos - id=${comentario.id}, titulo="${comentario.titulo}", ferramenta=${comentario.ferramenta}',
        name: 'ComentarioService',
        level: 500,
      );
      developer.log(
        'Criando entidade de sincronização',
        name: 'ComentarioService',
        level: 500,
      );
      final syncEntity = ComentarioSyncEntity(
        id: comentario.id,
        idReg: comentario.idReg,
        titulo: comentario.titulo,
        conteudo: comentario.conteudo,
        ferramenta: comentario.ferramenta,
        pkIdentificador: comentario.pkIdentificador,
        status: comentario.status,
        createdAt: comentario.createdAt,
        updatedAt: comentario.updatedAt,
        userId: userId,
      );
      developer.log(
        'Entidade de sincronização criada - syncEntity.id=${syncEntity.id}',
        name: 'ComentarioService',
        level: 500,
      );
      developer.log(
        'Executando operação de sync - $operation',
        name: 'ComentarioService',
        level: 500,
      );
      if (operation == 'create') {
        developer.log(
          'Chamando UnifiedSyncManager.create<ComentarioSyncEntity>()',
          name: 'ComentarioService',
          level: 500,
        );
        final result = await core.UnifiedSyncManager.instance
            .create<ComentarioSyncEntity>('receituagro', syncEntity);
        result.fold(
          (core.Failure failure) {
            developer.log(
              'Erro na sincronização de comentário (create)',
              name: 'ComentarioService',
              error: failure.message,
              level: 1000,
            );
          },
          (String entityId) {
            developer.log(
              'Comentário criado com sucesso: id=$entityId',
              name: 'ComentarioService',
              level: 500,
            );
          },
        );
      } else if (operation == 'delete') {
        developer.log(
          'Chamando UnifiedSyncManager.delete<ComentarioSyncEntity>()',
          name: 'ComentarioService',
          level: 500,
        );
        final result = await core.UnifiedSyncManager.instance
            .delete<ComentarioSyncEntity>('receituagro', syncEntity.id);
        result.fold(
          (core.Failure failure) {
            developer.log(
              'Erro na sincronização de comentário (delete)',
              name: 'ComentarioService',
              error: failure.message,
              level: 1000,
            );
          },
          (_) {
            developer.log(
              'Comentário deletado com sucesso: id=${comentario.id}',
              name: 'ComentarioService',
              level: 500,
            );
          },
        );
      } else {
        developer.log(
          'Chamando UnifiedSyncManager.update<ComentarioSyncEntity>()',
          name: 'ComentarioService',
          level: 500,
        );
        final result =
            await core.UnifiedSyncManager.instance.update<ComentarioSyncEntity>(
          'receituagro',
          syncEntity.id,
          syncEntity,
        );
        result.fold(
          (core.Failure failure) {
            developer.log(
              'Erro na sincronização de comentário (update)',
              name: 'ComentarioService',
              error: failure.message,
              level: 1000,
            );
          },
          (_) {
            developer.log(
              'Comentário atualizado com sucesso: id=${comentario.id}',
              name: 'ComentarioService',
              level: 500,
            );
          },
        );
      }

      developer.log(
        'Operação de sync $operation finalizada para comentario_id=${comentario.id}',
        name: 'ComentarioService',
        level: 500,
      );
    } catch (e) {
      developer.log(
        'Erro ao sincronizar comentário',
        name: 'ComentarioService',
        error: e,
        level: 1000,
      );
    }
  }
}
