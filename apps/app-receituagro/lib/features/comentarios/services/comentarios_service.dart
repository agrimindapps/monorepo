import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart' as core;

import '../../../core/interfaces/i_premium_service.dart';
import '../../../core/sync/receituagro_sync_config.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/di/injection_container.dart';
import '../domain/entities/comentario_sync_entity.dart';
import '../constants/comentarios_design_tokens.dart';
import '../models/comentario_model.dart';

abstract class IComentariosRepository {
  Future<List<ComentarioModel>> getAllComentarios();
  Future<void> addComentario(ComentarioModel comentario);
  Future<void> updateComentario(ComentarioModel comentario);
  Future<void> deleteComentario(String id);
}

class ComentariosService extends ChangeNotifier {
  final IComentariosRepository? _repository;
  final IPremiumService? _premiumService;
  final ReceitaAgroAuthProvider? _authProvider = sl.isRegistered<ReceitaAgroAuthProvider>() ? sl<ReceitaAgroAuthProvider>() : null;

  ComentariosService({
    IComentariosRepository? repository,
    IPremiumService? premiumService,
  }) : _repository = repository,
       _premiumService = premiumService;

  Future<List<ComentarioModel>> getAllComentarios({String? pkIdentificador}) async {
    try {
      final comentarios = await _repository?.getAllComentarios() ?? <ComentarioModel>[];
      
      // Sort by newest first
      comentarios.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Filter by identifier if provided
      if (pkIdentificador != null && pkIdentificador.isNotEmpty) {
        return comentarios
            .where((element) => element.pkIdentificador == pkIdentificador)
            .toList();
      }
      
      return comentarios;
    } catch (e) {
      debugPrint('Error getting comentarios: $e');
      return [];
    }
  }

  Future<void> addComentario(ComentarioModel comentario) async {
    try {
      await _repository?.addComentario(comentario);
      
      // Sincroniza com Firestore se usuário autenticado
      await _queueSyncOperation('create', comentario);
    } catch (e) {
      debugPrint('Error adding comentario: $e');
      rethrow;
    }
  }

  Future<void> updateComentario(ComentarioModel comentario) async {
    try {
      await _repository?.updateComentario(comentario);
      
      // Sincroniza com Firestore se usuário autenticado
      await _queueSyncOperation('update', comentario);
    } catch (e) {
      debugPrint('Error updating comentario: $e');
      rethrow;
    }
  }

  Future<void> deleteComentario(String id) async {
    try {
      await _repository?.deleteComentario(id);
      
      // Sincroniza com Firestore se usuário autenticado  
      await _queueSyncOperation('delete', ComentarioModel(
        id: id,
        idReg: '',
        titulo: '',
        conteudo: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ferramenta: '',
        pkIdentificador: '',
        status: false,
      ));
    } catch (e) {
      debugPrint('Error deleting comentario: $e');
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
      // Search filter
      if (searchText.isNotEmpty) {
        final searchLower = _sanitizeSearchText(searchText);
        final contentMatch = comentario.conteudo.toLowerCase().contains(searchLower);
        final toolMatch = comentario.ferramenta.toLowerCase().contains(searchLower);

        if (!contentMatch && !toolMatch) return false;
      }

      // Context filters
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
    // Limit length for performance
    if (text.length > ComentariosDesignTokens.maxSearchLength) {
      text = text.substring(0, ComentariosDesignTokens.maxSearchLength);
    }

    // Escape regex special characters for security
    return text.toLowerCase().replaceAll(RegExp(r'[\\\[\]{}()*+?.^$|]'), '');
  }

  int getMaxComentarios() {
    // Temporariamente sem limites
    return ComentariosDesignTokens.freeTierMaxComments;
  }

  bool canAddComentario(int currentCount) {
    final maxComentarios = getMaxComentarios();
    return currentCount < maxComentarios;
  }

  bool hasAdvancedFeatures() {
    // Temporariamente todas as features estão disponíveis
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
    // Simple ID generation - replace with actual database utility if available
    return 'REG_${DateTime.now().millisecondsSinceEpoch}';
  }

  bool isValidContent(String content) {
    return content.trim().length >= ComentariosDesignTokens.minCommentLength;
  }

  String getValidationErrorMessage() {
    return ComentariosDesignTokens.shortCommentError;
  }

  /// Sincroniza comentário usando sistema core
  Future<void> _queueSyncOperation(String operation, ComentarioModel comentario) async {
    try {
      // Verifica se o usuário está autenticado
      if (_authProvider == null || !_authProvider!.isAuthenticated || _authProvider!.isAnonymous) {
        debugPrint('Usuário não autenticado - pulando sincronização de comentário');
        return;
      }

      // Verifica se há dados válidos para sincronização
      if (comentario.id.isEmpty) {
        debugPrint('ID do comentário inválido - pulando sincronização');
        return;
      }

      // Cria entidade de sincronização
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
        userId: _authProvider!.currentUser?.id,
      );

      // Executa operação de sincronização via ReceitaAgroSyncConfig
      if (operation == 'create') {
        final result = await ReceitaAgroSyncConfig.createComentario(syncEntity);
        result.fold(
          (core.Failure failure) {
            debugPrint('Erro na sincronização de comentário (create): ${failure.message}');
          },
          (String entityId) {
            debugPrint('Comentário criado com sucesso: id=$entityId');
          },
        );
      } else if (operation == 'delete') {
        final result = await ReceitaAgroSyncConfig.deleteComentario(syncEntity.id);
        result.fold(
          (core.Failure failure) {
            debugPrint('Erro na sincronização de comentário (delete): ${failure.message}');
          },
          (_) {
            debugPrint('Comentário deletado com sucesso: id=${comentario.id}');
          },
        );
      } else {
        final result = await ReceitaAgroSyncConfig.updateComentario(syncEntity.id, syncEntity);
        result.fold(
          (core.Failure failure) {
            debugPrint('Erro na sincronização de comentário (update): ${failure.message}');
          },
          (_) {
            debugPrint('Comentário atualizado com sucesso: id=${comentario.id}');
          },
        );
      }
      
    } catch (e) {
      debugPrint('Erro ao sincronizar comentário: $e');
      // Não relança a exceção para não quebrar a operação local
    }
  }
}