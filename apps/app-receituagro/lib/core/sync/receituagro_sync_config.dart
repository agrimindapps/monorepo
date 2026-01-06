import 'package:core/core.dart' hide Column;

import '../../features/comentarios/domain/entities/comentario_sync_entity.dart';
import '../../features/favoritos/domain/entities/favorito_sync_entity.dart';
import '../../features/settings/domain/entities/user_history_sync_entity.dart';
import '../../features/settings/domain/entities/user_settings_sync_entity.dart';
import '../extensions/user_entity_receituagro_extension.dart';
import '../providers/core_providers.dart';

FavoritoSyncEntity _favoritoFromFirebaseMap(Map<String, dynamic> map) {
  return FavoritoSyncEntity.fromMap(map);
}

Map<String, dynamic> _favoritoToFirebaseMap(BaseSyncEntity entity) {
  return (entity as FavoritoSyncEntity).toMap();
}

ComentarioSyncEntity _comentarioFromFirebaseMap(Map<String, dynamic> map) {
  return ComentarioSyncEntity.fromMap(map);
}

Map<String, dynamic> _comentarioToFirebaseMap(BaseSyncEntity entity) {
  return (entity as ComentarioSyncEntity).toMap();
}

UserSettingsSyncEntity _userSettingsFromFirebaseMap(Map<String, dynamic> map) {
  return UserSettingsSyncEntity.fromFirebaseMap(map);
}

Map<String, dynamic> _userSettingsToFirebaseMap(BaseSyncEntity entity) {
  return (entity as UserSettingsSyncEntity).toMap();
}

UserHistorySyncEntity _userHistoryFromFirebaseMap(Map<String, dynamic> map) {
  return UserHistorySyncEntity.fromFirebaseMap(map);
}

UserEntity _userEntityFromFirebaseMap(Map<String, dynamic> map) {
  return UserEntityReceitaAgroExtension.fromReceitaAgroFirebaseMap(map);
}

Map<String, dynamic> _userEntityToFirebaseMap(BaseSyncEntity entity) {
  return (entity as UserEntity).toReceitaAgroFirebaseMap();
}

/// Configuração de sincronização específica do ReceitaAgro
/// Diagnóstico agrícola com favoritos, comentários e dados do usuário
abstract final class ReceitaAgroSyncConfig {
  /// Configura o sistema de sincronização para o ReceitaAgro
  /// ✅ SYNC ATIVADO com ReceituagroDriftStorageAdapter
  /// Sincroniza: Favoritos, Comentários e AppSettings
  static Future<void> configure(ProviderContainer container) async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'receituagro',
      localStorage: container.read(localStorageRepositoryProvider),
      config: AppSyncConfig.advanced(
        appName: 'receituagro',
        syncInterval: const Duration(minutes: 2),
        conflictStrategy: ConflictStrategy.timestamp,
        enableOrchestration: false,
      ),
      entities: [
        // Favoritos com realtime sync habilitado
        const EntitySyncRegistration<FavoritoSyncEntity>(
          entityType: FavoritoSyncEntity,
          collectionName: 'favoritos',
          fromMap: _favoritoFromFirebaseMap,
          toMap: _favoritoToFirebaseMap,
          conflictStrategy: ConflictStrategy.timestamp,
          enableRealtime: true, // Sincronização em tempo real
          syncInterval: Duration(minutes: 2),
        ),
        // Comentários com realtime sync habilitado
        const EntitySyncRegistration<ComentarioSyncEntity>(
          entityType: ComentarioSyncEntity,
          collectionName: 'comentarios',
          fromMap: _comentarioFromFirebaseMap,
          toMap: _comentarioToFirebaseMap,
          conflictStrategy: ConflictStrategy.timestamp,
          enableRealtime: true, // Sincronização em tempo real
          syncInterval: Duration(minutes: 2),
        ),
        // User settings com realtime sync habilitado
        const EntitySyncRegistration<UserSettingsSyncEntity>(
          entityType: UserSettingsSyncEntity,
          collectionName: 'user_settings',
          fromMap: _userSettingsFromFirebaseMap,
          toMap: _userSettingsToFirebaseMap,
          conflictStrategy: ConflictStrategy.remoteWins, // Remote vence para settings
          enableRealtime: true, // Sincronização em tempo real
          syncInterval: Duration(minutes: 5),
        ),
        // User entity para sincronização de perfil do usuário
        const EntitySyncRegistration<UserEntity>(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: _userEntityFromFirebaseMap,
          toMap: _userEntityToFirebaseMap,
          conflictStrategy: ConflictStrategy.remoteWins, // Remote vence para dados do usuário
          enableRealtime: false, // Não precisa de realtime para perfil
          syncInterval: Duration(minutes: 10),
        ),
      ],
    );
  }

  /// Configuração para desenvolvimento
  static Future<void> configureDevelopment(ProviderContainer container) async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'receituagro',
      localStorage: container.read(localStorageRepositoryProvider),
      config: AppSyncConfig.development(
        appName: 'receituagro',
        syncInterval: const Duration(minutes: 1),
      ),
      entities: [
        EntitySyncRegistration<FavoritoSyncEntity>.simple(
          entityType: FavoritoSyncEntity,
          collectionName: 'dev_favoritos',
          fromMap: _favoritoFromFirebaseMap,
          toMap: (favorito) => favorito.toMap(),
        ),

        EntitySyncRegistration<ComentarioSyncEntity>.simple(
          entityType: ComentarioSyncEntity,
          collectionName: 'dev_comentarios',
          fromMap: _comentarioFromFirebaseMap,
          toMap: (comentario) => comentario.toMap(),
        ),

        EntitySyncRegistration<UserSettingsSyncEntity>.simple(
          entityType: UserSettingsSyncEntity,
          collectionName: 'dev_user_settings',
          fromMap: _userSettingsFromFirebaseMap,
          toMap: (settings) => settings.toMap(),
        ),

        EntitySyncRegistration<UserHistorySyncEntity>.simple(
          entityType: UserHistorySyncEntity,
          collectionName: 'dev_user_history',
          fromMap: _userHistoryFromFirebaseMap,
          toMap: (history) => history.toMap(),
        ),

        EntitySyncRegistration<UserEntity>.simple(
          entityType: UserEntity,
          collectionName: 'dev_users',
          fromMap: _userEntityFromFirebaseMap,
          toMap: (user) => user.toReceitaAgroFirebaseMap(),
        ),

        EntitySyncRegistration<SubscriptionEntity>.simple(
          entityType: SubscriptionEntity,
          collectionName: 'dev_subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (subscription) => subscription.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração offline-first para áreas rurais com internet limitada
  static Future<void> configureOfflineFirst(ProviderContainer container) async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'receituagro',
      localStorage: container.read(localStorageRepositoryProvider),
      config: AppSyncConfig.offlineFirst(
        appName: 'receituagro',
        syncInterval: const Duration(hours: 6), // Sync esporádico
      ),
      entities: [
        EntitySyncRegistration<FavoritoSyncEntity>(
          entityType: FavoritoSyncEntity,
          collectionName: 'favoritos',
          fromMap: _favoritoFromFirebaseMap,
          toMap: (FavoritoSyncEntity favorito) => favorito.toMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 50,
        ),

        EntitySyncRegistration<ComentarioSyncEntity>(
          entityType: ComentarioSyncEntity,
          collectionName: 'comentarios',
          fromMap: _comentarioFromFirebaseMap,
          toMap: (ComentarioSyncEntity comentario) => comentario.toMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 50,
        ),

        EntitySyncRegistration<UserSettingsSyncEntity>(
          entityType: UserSettingsSyncEntity,
          collectionName: 'user_settings',
          fromMap: _userSettingsFromFirebaseMap,
          toMap: (UserSettingsSyncEntity settings) => settings.toMap(),
          conflictStrategy:
              ConflictStrategy.remoteWins, // Remote vence para settings
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 24),
          batchSize: 10,
        ),

        EntitySyncRegistration<UserHistorySyncEntity>(
          entityType: UserHistorySyncEntity,
          collectionName: 'user_history',
          fromMap: _userHistoryFromFirebaseMap,
          toMap: (UserHistorySyncEntity history) => history.toMap(),
          conflictStrategy:
              ConflictStrategy.localWins, // Local vence para histórico
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 24),
          batchSize: 100, // Maior batch para histórico
        ),

        EntitySyncRegistration<UserEntity>(
          entityType: UserEntity,
          collectionName: 'users',
          fromMap: _userEntityFromFirebaseMap,
          toMap: (UserEntity user) => user.toReceitaAgroFirebaseMap(),
          conflictStrategy:
              ConflictStrategy.remoteWins, // Remote vence para usuários
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 24),
          batchSize: 10,
        ),

        EntitySyncRegistration<SubscriptionEntity>(
          entityType: SubscriptionEntity,
          collectionName: 'subscriptions',
          fromMap: SubscriptionEntity.fromFirebaseMap,
          toMap: (SubscriptionEntity subscription) =>
              subscription.toFirebaseMap(),
          conflictStrategy: ConflictStrategy
              .remoteWins, // Remote sempre vence para assinaturas
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 24),
          batchSize: 5,
        ),
      ],
    );
  }
}
