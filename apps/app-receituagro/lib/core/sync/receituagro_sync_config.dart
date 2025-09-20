import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../features/comentarios/domain/entities/comentario_sync_entity.dart';
import '../../features/favoritos/domain/entities/favorito_sync_entity.dart';
import '../entities/user_profile_sync_entity.dart';

/// Configuração de sincronização específica para o app ReceitaAgro
class ReceitaAgroSyncConfig {
  
  /// Inicializa a configuração de sincronização para o app
  static Future<void> initializeSync() async {
    print('🔄 RECEITUAGRO_SYNC: Iniciando configuração de sincronização...');
    late UnifiedSyncManager syncManager;
    
    try {
      syncManager = UnifiedSyncManager.instance;
      print('🔄 RECEITUAGRO_SYNC: UnifiedSyncManager instanciado - $syncManager');
    } catch (e) {
      print('❌ RECEITUAGRO_SYNC: Erro ao instanciar UnifiedSyncManager: $e');
      rethrow;
    }
    
    // Configuração do app
    final appConfig = AppSyncConfig(
      appName: 'receituagro',
      syncInterval: const Duration(minutes: 2), // Sync mais frequente
      batchSize: 50,
      globalConflictStrategy: ConflictStrategy.remoteWins,
      maxRetries: 3,
      enableRealtimeSync: true,
    );
    print('🔄 RECEITUAGRO_SYNC: AppSyncConfig criado - appName: receituagro');
    
    // Lista de entidades para sincronizar
    final entities = [
      // Favoritos
      EntitySyncRegistration<FavoritoSyncEntity>(
        entityType: FavoritoSyncEntity,
        collectionName: 'favoritos',
        fromMap: FavoritoSyncEntity.fromMap,
        toMap: (entity) => (entity as FavoritoSyncEntity).toMap(),
        conflictStrategy: ConflictStrategy.timestamp,
        batchSize: 25,
        maxRetries: 3,
      ),
      
      // Comentários
      EntitySyncRegistration<ComentarioSyncEntity>(
        entityType: ComentarioSyncEntity,
        collectionName: 'comentarios',
        fromMap: ComentarioSyncEntity.fromMap,
        toMap: (entity) => (entity as ComentarioSyncEntity).toMap(),
        conflictStrategy: ConflictStrategy.timestamp,
        batchSize: 25,
        maxRetries: 3,
      ),
      
      // Perfil do usuário
      EntitySyncRegistration<UserProfileSyncEntity>(
        entityType: UserProfileSyncEntity,
        collectionName: 'user_profiles',
        fromMap: UserProfileSyncEntity.fromMap,
        toMap: (entity) => (entity as UserProfileSyncEntity).toMap(),
        conflictStrategy: ConflictStrategy.timestamp,
        batchSize: 10,
        maxRetries: 5, // Mais tentativas para perfil
      ),
    ];
    print('🔄 RECEITUAGRO_SYNC: ${entities.length} entidades criadas para registro');
    
    // Registrar no UnifiedSyncManager
    print('🔄 RECEITUAGRO_SYNC: Registrando app no UnifiedSyncManager...');
    try {
      final result = await syncManager.initializeApp(
        appName: 'receituagro',
        config: appConfig,
        entities: entities,
      );
      
      print('🔄 RECEITUAGRO_SYNC: initializeApp() retornou resultado');
      
      result.fold(
        (failure) {
          print('❌ RECEITUAGRO_SYNC: Erro ao inicializar sync: ${failure.message}');
        },
        (_) {
          print('✅ RECEITUAGRO_SYNC: ReceitaAgro sync inicializado com sucesso!');
          print('📦 RECEITUAGRO_SYNC: Entidades registradas: favoritos, comentarios, user_profiles');
        },
      );
    } catch (e) {
      print('❌ RECEITUAGRO_SYNC: Erro em initializeApp(): $e');
      rethrow;
    }
  }
  
  /// Obtém repositório de sync para favoritos
  /// DEPRECADO: Use os métodos createFavorito, updateFavorito, deleteFavorito
  static ISyncRepository<FavoritoSyncEntity>? getFavoritosRepository() {
    // Método privado não é acessível, use os wrappers públicos
    return null;
  }
  
  /// Obtém repositório de sync para comentários
  /// DEPRECADO: Use os métodos createComentario, updateComentario, deleteComentario
  static ISyncRepository<ComentarioSyncEntity>? getComentariosRepository() {
    // Método privado não é acessível, use os wrappers públicos
    return null;
  }
  
  /// Obtém repositório de sync para perfil do usuário
  static ISyncRepository<UserProfileSyncEntity>? getUserProfileRepository() {
    // Método privado não é acessível, use os wrappers públicos
    return null;
  }
  
  /// Wrapper para criar entidade via UnifiedSyncManager
  static Future<Either<Failure, String>> createFavorito(FavoritoSyncEntity entity) {
    print('🚀 UNIFIED_SYNC: createFavorito() - entityId=${entity.id}, userId=${entity.userId}');
    final result = UnifiedSyncManager.instance.create<FavoritoSyncEntity>('receituagro', entity);
    
    result.then((either) {
      either.fold(
        (failure) => print('❌ UNIFIED_SYNC: createFavorito() falhou - ${failure.message}'),
        (entityId) => print('✅ UNIFIED_SYNC: createFavorito() sucesso - firestore_id=$entityId'),
      );
    }).catchError((error) {
      print('❌ UNIFIED_SYNC: createFavorito() erro - $error');
    });
    
    return result;
  }
  
  /// Wrapper para atualizar entidade via UnifiedSyncManager
  static Future<Either<Failure, void>> updateFavorito(String id, FavoritoSyncEntity entity) {
    return UnifiedSyncManager.instance.update<FavoritoSyncEntity>('receituagro', id, entity);
  }
  
  /// Wrapper para deletar entidade via UnifiedSyncManager
  static Future<Either<Failure, void>> deleteFavorito(String id) {
    print('🗑️ UNIFIED_SYNC: deleteFavorito() - entityId=$id');
    final result = UnifiedSyncManager.instance.delete<FavoritoSyncEntity>('receituagro', id);
    
    result.then((either) {
      either.fold(
        (failure) => print('❌ UNIFIED_SYNC: deleteFavorito() falhou - ${failure.message}'),
        (_) => print('✅ UNIFIED_SYNC: deleteFavorito() sucesso - entityId=$id'),
      );
    }).catchError((error) {
      print('❌ UNIFIED_SYNC: deleteFavorito() erro - $error');
    });
    
    return result;
  }
  
  /// Wrapper para criar comentário via UnifiedSyncManager
  static Future<Either<Failure, String>> createComentario(ComentarioSyncEntity entity) {
    return UnifiedSyncManager.instance.create<ComentarioSyncEntity>('receituagro', entity);
  }
  
  /// Wrapper para atualizar comentário via UnifiedSyncManager
  static Future<Either<Failure, void>> updateComentario(String id, ComentarioSyncEntity entity) {
    return UnifiedSyncManager.instance.update<ComentarioSyncEntity>('receituagro', id, entity);
  }
  
  /// Wrapper para deletar comentário via UnifiedSyncManager
  static Future<Either<Failure, void>> deleteComentario(String id) {
    return UnifiedSyncManager.instance.delete<ComentarioSyncEntity>('receituagro', id);
  }
  
  /// Wrapper para criar perfil de usuário via UnifiedSyncManager
  static Future<Either<Failure, String>> createUserProfile(UserProfileSyncEntity entity) {
    return UnifiedSyncManager.instance.create<UserProfileSyncEntity>('receituagro', entity);
  }
  
  /// Wrapper para atualizar perfil de usuário via UnifiedSyncManager
  static Future<Either<Failure, void>> updateUserProfile(String id, UserProfileSyncEntity entity) {
    return UnifiedSyncManager.instance.update<UserProfileSyncEntity>('receituagro', id, entity);
  }
}