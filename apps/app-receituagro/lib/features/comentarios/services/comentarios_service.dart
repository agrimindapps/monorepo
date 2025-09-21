import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/interfaces/i_premium_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../constants/comentarios_design_tokens.dart';
import '../domain/entities/comentario_sync_entity.dart';
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
    print('💬 COMENTARIO_SERVICE: Adicionando comentário - id=${comentario.id}, titulo="${comentario.titulo}"');
    try {
      print('📁 COMENTARIO_SERVICE: Salvando no repositório local...');
      await _repository?.addComentario(comentario);
      print('✅ COMENTARIO_SERVICE: Comentário salvo localmente com sucesso');
      
      // Sincroniza com Firestore se usuário autenticado
      print('🔄 COMENTARIO_SERVICE: Iniciando sincronização...');
      await _queueSyncOperation('create', comentario);
    } catch (e) {
      print('❌ COMENTARIO_SERVICE: Error adding comentario: $e');
      rethrow;
    }
  }

  Future<void> updateComentario(ComentarioModel comentario) async {
    print('💬 COMENTARIO_SERVICE: Atualizando comentário - id=${comentario.id}, titulo="${comentario.titulo}"');
    try {
      print('📁 COMENTARIO_SERVICE: Atualizando no repositório local...');
      await _repository?.updateComentario(comentario);
      print('✅ COMENTARIO_SERVICE: Comentário atualizado localmente com sucesso');
      
      // Sincroniza com Firestore se usuário autenticado
      print('🔄 COMENTARIO_SERVICE: Iniciando sincronização...');
      await _queueSyncOperation('update', comentario);
    } catch (e) {
      print('❌ COMENTARIO_SERVICE: Error updating comentario: $e');
      rethrow;
    }
  }

  Future<void> deleteComentario(String id) async {
    print('💬 COMENTARIO_SERVICE: Deletando comentário - id=$id');
    try {
      print('📁 COMENTARIO_SERVICE: Removendo do repositório local...');
      await _repository?.deleteComentario(id);
      print('✅ COMENTARIO_SERVICE: Comentário removido localmente com sucesso');
      
      // Sincroniza com Firestore se usuário autenticado  
      print('🔄 COMENTARIO_SERVICE: Iniciando sincronização de deleção...');
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
      print('❌ COMENTARIO_SERVICE: Error deleting comentario: $e');
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
    print('💬 COMENTARIO_SERVICE: Iniciando operação de sync - operation=$operation, comentario_id=${comentario.id}');
    try {
      // Verifica se o usuário está autenticado
      if (_authProvider == null || !_authProvider.isAuthenticated || _authProvider.isAnonymous) {
        print('⚠️ COMENTARIO_SERVICE: Usuário não autenticado - pulando sincronização de comentário');
        return;
      }
      
      print('✅ COMENTARIO_SERVICE: Usuário autenticado - userId=${_authProvider.currentUser?.id}');

      // Verifica se há dados válidos para sincronização
      if (comentario.id.isEmpty) {
        print('❌ COMENTARIO_SERVICE: ID do comentário inválido - pulando sincronização');
        return;
      }
      
      print('📄 COMENTARIO_SERVICE: Dados do comentário válidos - id=${comentario.id}, titulo="${comentario.titulo}", ferramenta=${comentario.ferramenta}');

      // Cria entidade de sincronização
      print('🔄 COMENTARIO_SERVICE: Criando entidade de sincronização...');
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
        userId: _authProvider.currentUser?.id,
      );
      print('✅ COMENTARIO_SERVICE: Entidade de sincronização criada - syncEntity.id=${syncEntity.id}');

      // Executa operação de sincronização via UnifiedSyncManager
      print('🚀 COMENTARIO_SERVICE: Executando operação de sync - $operation');
      if (operation == 'create') {
        print('🆕 COMENTARIO_SERVICE: Chamando UnifiedSyncManager.create<ComentarioSyncEntity>()...');
        final result = await core.UnifiedSyncManager.instance.create<ComentarioSyncEntity>('receituagro', syncEntity);
        result.fold(
          (core.Failure failure) {
            print('❌ COMENTARIO_SERVICE: Erro na sincronização de comentário (create): ${failure.message}');
          },
          (String entityId) {
            print('✅ COMENTARIO_SERVICE: Comentário criado com sucesso: id=$entityId');
          },
        );
      } else if (operation == 'delete') {
        print('🗜 COMENTARIO_SERVICE: Chamando UnifiedSyncManager.delete<ComentarioSyncEntity>()...');
        final result = await core.UnifiedSyncManager.instance.delete<ComentarioSyncEntity>('receituagro', syncEntity.id);
        result.fold(
          (core.Failure failure) {
            print('❌ COMENTARIO_SERVICE: Erro na sincronização de comentário (delete): ${failure.message}');
          },
          (_) {
            print('✅ COMENTARIO_SERVICE: Comentário deletado com sucesso: id=${comentario.id}');
          },
        );
      } else {
        print('🔄 COMENTARIO_SERVICE: Chamando UnifiedSyncManager.update<ComentarioSyncEntity>()...');
        final result = await core.UnifiedSyncManager.instance.update<ComentarioSyncEntity>('receituagro', syncEntity.id, syncEntity);
        result.fold(
          (core.Failure failure) {
            print('❌ COMENTARIO_SERVICE: Erro na sincronização de comentário (update): ${failure.message}');
          },
          (_) {
            print('✅ COMENTARIO_SERVICE: Comentário atualizado com sucesso: id=${comentario.id}');
          },
        );
      }
      
      print('✨ COMENTARIO_SERVICE: Operação de sync $operation finalizada para comentario_id=${comentario.id}');
      
    } catch (e) {
      print('❌ COMENTARIO_SERVICE: Erro ao sincronizar comentário: $e');
      // Não relança a exceção para não quebrar a operação local
    }
  }
}