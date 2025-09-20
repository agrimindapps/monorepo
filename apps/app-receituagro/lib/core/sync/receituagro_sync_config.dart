import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../features/comentarios/domain/entities/comentario_sync_entity.dart';
import '../../features/favoritos/domain/entities/favorito_sync_entity.dart';
import '../entities/user_profile_sync_entity.dart';

/// Configuração de sincronização específica para o app ReceitaAgro
class ReceitaAgroSyncConfig {
  
  /// Inicializa a configuração de sincronização para o app
  static Future<void> initializeSync() async {
    final syncManager = UnifiedSyncManager.instance;
    
    // Configuração do app
    final appConfig = AppSyncConfig(
      appName: 'receituagro',
      syncInterval: const Duration(minutes: 2), // Sync mais frequente
      batchSize: 50,
      globalConflictStrategy: ConflictStrategy.remoteWins,
      maxRetries: 3,
      enableRealtimeSync: true,
    );
    
    // Lista de entidades para sincronizar
    final entities = [
      // Favoritos
      EntitySyncRegistration<FavoritoSyncEntity>(
        entityType: FavoritoSyncEntity,
        collectionName: 'favoritos',
        fromMap: FavoritoSyncEntity.fromMap,
        toMap: (entity) => entity.toMap(),
        conflictStrategy: ConflictStrategy.timestamp,
        batchSize: 25,
        maxRetries: 3,
      ),
      
      // Comentários
      EntitySyncRegistration<ComentarioSyncEntity>(
        entityType: ComentarioSyncEntity,
        collectionName: 'comentarios',
        fromMap: ComentarioSyncEntity.fromMap,
        toMap: (entity) => entity.toMap(),
        conflictStrategy: ConflictStrategy.timestamp,
        batchSize: 25,
        maxRetries: 3,
      ),
      
      // Perfil do usuário
      EntitySyncRegistration<UserProfileSyncEntity>(
        entityType: UserProfileSyncEntity,
        collectionName: 'user_profiles',
        fromMap: UserProfileSyncEntity.fromMap,
        toMap: (entity) => entity.toMap(),
        conflictStrategy: ConflictStrategy.timestamp,
        batchSize: 10,
        maxRetries: 5, // Mais tentativas para perfil
      ),
    ];
    
    // Registrar no UnifiedSyncManager
    final result = await syncManager.initializeApp(
      appName: 'receituagro',
      config: appConfig,
      entities: entities,
    );
    
    result.fold(
      (failure) {
        print('❌ Erro ao inicializar sync: ${failure.message}');
      },
      (_) {
        print('✅ ReceitaAgro sync inicializado com sucesso');
      },
    );
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
    return UnifiedSyncManager.instance.create<FavoritoSyncEntity>('receituagro', entity);
  }
  
  /// Wrapper para atualizar entidade via UnifiedSyncManager
  static Future<Either<Failure, void>> updateFavorito(String id, FavoritoSyncEntity entity) {
    return UnifiedSyncManager.instance.update<FavoritoSyncEntity>('receituagro', id, entity);
  }
  
  /// Wrapper para deletar entidade via UnifiedSyncManager
  static Future<Either<Failure, void>> deleteFavorito(String id) {
    return UnifiedSyncManager.instance.delete<FavoritoSyncEntity>('receituagro', id);
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