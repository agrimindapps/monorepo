import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../features/comentarios/data/comentario_model.dart';
import '../../../features/favoritos/data/favorito_defensivo_model.dart';
import '../models/app_settings_model.dart';

/// Repository para gerenciar dados específicos do usuário com sincronização
class UserDataRepository {
  static const String _appSettingsBoxName = 'app_settings';
  static const String _subscriptionDataBoxName = 'subscription_data';

  UserDataRepository();

  /// Obtém o userId atual via Firebase Auth (synchronous access)
  String? get currentUserId {
    try {
      return firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se há um usuário logado
  bool get hasCurrentUser => currentUserId != null;

  // =============================================================================
  // APP SETTINGS
  // =============================================================================

  /// Obtém configurações do app para o usuário atual
  Future<Either<Exception, AppSettingsModel?>> getAppSettings() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final box = await Hive.openBox<AppSettingsModel>(_appSettingsBoxName);
      final settings = box.values
          .where((settings) => settings.userId == userId)
          .firstOrNull;

      return Right(settings);
    } catch (e) {
      return Left(Exception('Error getting app settings: $e'));
    }
  }

  /// Salva configurações do app para o usuário atual
  Future<Either<Exception, void>> saveAppSettings(AppSettingsModel settings) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final box = await Hive.openBox<AppSettingsModel>(_appSettingsBoxName);
      
      // Verificar se já existe configuração para o usuário
      final existingKey = box.keys.firstWhere(
        (key) => box.get(key)?.userId == userId,
        orElse: () => null,
      );

      final updatedSettings = settings.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
        synchronized: false, // Marca como não sincronizado
      );

      if (existingKey != null) {
        await box.put(existingKey, updatedSettings);
      } else {
        await box.add(updatedSettings);
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error saving app settings: $e'));
    }
  }

  /// Cria configurações padrão para o usuário atual
  Future<Either<Exception, AppSettingsModel>> createDefaultAppSettings() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final defaultSettings = AppSettingsModel(
        userId: userId,
        createdAt: DateTime.now(),
        synchronized: false,
      );

      final saveResult = await saveAppSettings(defaultSettings);
      return saveResult.fold(
        (error) => Left(error),
        (_) => Right(defaultSettings),
      );
    } catch (e) {
      return Left(Exception('Error creating default app settings: $e'));
    }
  }

  // =============================================================================
  // SUBSCRIPTION DATA  
  // =============================================================================

  /// Obtém dados de subscription para o usuário atual
  Future<Either<Exception, SubscriptionEntity?>> getSubscriptionData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Temporariamente ainda usa Hive com SubscriptionDataModel para compatibilidade
      // Será migrado para usar o sistema unificado gradualmente
      final box = await Hive.openBox<Map<dynamic, dynamic>>(_subscriptionDataBoxName);
      final subscriptionMap = box.values
          .where((sub) => sub['userId'] == userId)
          .firstOrNull;

      if (subscriptionMap == null) {
        return const Right(null);
      }

      // Converter Map para SubscriptionEntity via adaptador
      try {
        final entity = SubscriptionEntity.fromFirebaseMap(
          Map<String, dynamic>.from(subscriptionMap),
        );
        return Right(entity);
      } catch (e) {
        return Left(Exception('Error parsing subscription data: $e'));
      }
    } catch (e) {
      return Left(Exception('Error getting subscription data: $e'));
    }
  }

  /// Salva dados de subscription para o usuário atual
  Future<Either<Exception, void>> saveSubscriptionData(SubscriptionEntity subscription) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final box = await Hive.openBox<Map<dynamic, dynamic>>(_subscriptionDataBoxName);
      
      // Verificar se já existe subscription para o usuário
      final existingKey = box.keys.firstWhere(
        (key) {
          final sub = box.get(key);
          return sub != null && sub['userId'] == userId;
        },
        orElse: () => null,
      );

      final updatedSubscription = subscription.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
        isDirty: true, // Marca como não sincronizado
      );

      // Converter para Map para salvar no Hive temporariamente
      final subscriptionMap = updatedSubscription.toFirebaseMap();

      if (existingKey != null) {
        await box.put(existingKey, subscriptionMap);
      } else {
        await box.add(subscriptionMap);
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error saving subscription data: $e'));
    }
  }

  // =============================================================================
  // FAVORITOS
  // =============================================================================

  /// Obtém favoritos do usuário atual
  Future<Either<Exception, List<FavoritoDefensivoModel>>> getFavoritos() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Por enquanto, retorna lista vazia - implementação depende do storage usado
      // Aqui seria a integração com o repository/service que gerencia favoritos
      
      return const Right([]);
    } catch (e) {
      return Left(Exception('Error getting favoritos: $e'));
    }
  }

  /// Salva favorito para o usuário atual
  Future<Either<Exception, void>> saveFavorito(FavoritoDefensivoModel favorito) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Marcar favorito com userId e como não sincronizado
      favorito.copyWith(
        userId: userId,
        synchronized: false,
        updatedAt: DateTime.now(),
      );

      // Aqui seria a integração com o repository/service que gerencia favoritos
      // Por exemplo: await _favoritosService.save(favorito);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error saving favorito: $e'));
    }
  }

  /// Remove favorito do usuário atual
  Future<Either<Exception, void>> removeFavorito(int favoritoId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Aqui seria a integração com o repository/service que gerencia favoritos
      // Por exemplo: await _favoritosService.remove(favoritoId, userId);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error removing favorito: $e'));
    }
  }

  // =============================================================================
  // COMENTARIOS
  // =============================================================================

  /// Obtém comentários do usuário atual
  Future<Either<Exception, List<ComentarioModel>>> getComentarios() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Por enquanto, retorna lista vazia - implementação depende do storage usado
      // Aqui seria a integração com o repository/service que gerencia comentários
      
      return const Right([]);
    } catch (e) {
      return Left(Exception('Error getting comentarios: $e'));
    }
  }

  /// Salva comentário para o usuário atual
  Future<Either<Exception, void>> saveComentario(ComentarioModel comentario) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Marcar comentário com userId e como não sincronizado
      comentario.copyWith(
        userId: userId,
        synchronized: false,
        syncedAt: null,
        updatedAt: DateTime.now(),
      );

      // Aqui seria a integração com o repository/service que gerencia comentários
      // Por exemplo: await _comentariosService.save(comentario);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error saving comentario: $e'));
    }
  }

  /// Remove comentário do usuário atual
  Future<Either<Exception, void>> removeComentario(String comentarioId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Aqui seria a integração com o repository/service que gerencia comentários
      // Por exemplo: await _comentariosService.remove(comentarioId, userId);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error removing comentario: $e'));
    }
  }

  // =============================================================================
  // SYNC OPERATIONS
  // =============================================================================

  /// Obtém todos os itens não sincronizados do usuário
  Future<Either<Exception, Map<String, List<dynamic>>>> getUnsynchronizedData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final unsynchronizedData = <String, List<dynamic>>{};

      // App Settings não sincronizados
      final settingsResult = await getAppSettings();
      settingsResult.fold(
        (error) => null,
        (settings) {
          if (settings != null && !settings.synchronized) {
            unsynchronizedData['app_settings'] = [settings];
          }
        },
      );

      // Subscription Data não sincronizada
      final subscriptionResult = await getSubscriptionData();
      subscriptionResult.fold(
        (error) => null,
        (subscription) {
          if (subscription != null && subscription.isDirty) {
            unsynchronizedData['subscription_data'] = [subscription];
          }
        },
      );

      // Favoritos não sincronizados
      final favoritosResult = await getFavoritos();
      favoritosResult.fold(
        (error) => null,
        (favoritos) {
          final unsyncedFavoritos = favoritos.where((f) => !f.synchronized).toList();
          if (unsyncedFavoritos.isNotEmpty) {
            unsynchronizedData['favoritos'] = unsyncedFavoritos;
          }
        },
      );

      // Comentários não sincronizados
      final comentariosResult = await getComentarios();
      comentariosResult.fold(
        (error) => null,
        (comentarios) {
          final unsyncedComentarios = comentarios.where((c) => !c.synchronized).toList();
          if (unsyncedComentarios.isNotEmpty) {
            unsynchronizedData['comentarios'] = unsyncedComentarios;
          }
        },
      );

      return Right(unsynchronizedData);
    } catch (e) {
      return Left(Exception('Error getting unsynchronized data: $e'));
    }
  }

  /// Marca item como sincronizado
  Future<Either<Exception, void>> markAsSynchronized({
    required String type,
    required String itemId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      switch (type) {
        case 'app_settings':
          final settingsResult = await getAppSettings();
          return settingsResult.fold(
            (error) => Left(error),
            (settings) async {
              if (settings != null) {
                final syncedSettings = settings.markAsSynchronized();
                return await saveAppSettings(syncedSettings);
              }
              return Left(Exception('Settings not found'));
            },
          );

        case 'subscription_data':
          final subscriptionResult = await getSubscriptionData();
          return subscriptionResult.fold(
            (error) => Left(error),
            (subscription) async {
              if (subscription != null) {
                final syncedSubscription = subscription.markAsSynced();
                return await saveSubscriptionData(syncedSubscription);
              }
              return Left(Exception('Subscription not found'));
            },
          );

        case 'favoritos':
          // Implementar conforme necessário
          return const Right(null);

        case 'comentarios':
          // Implementar conforme necessário
          return const Right(null);

        default:
          return Left(Exception('Unknown item type: $type'));
      }
    } catch (e) {
      return Left(Exception('Error marking item as synchronized: $e'));
    }
  }

  /// Limpa todos os dados do usuário atual (para logout)
  Future<Either<Exception, void>> clearUserData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Limpar app settings
      final appSettingsBox = await Hive.openBox<AppSettingsModel>(_appSettingsBoxName);
      final settingsKeysToRemove = appSettingsBox.keys
          .where((key) => appSettingsBox.get(key)?.userId == userId)
          .toList();
      
      for (final key in settingsKeysToRemove) {
        await appSettingsBox.delete(key);
      }

      // Limpar subscription data
      final subscriptionBox = await Hive.openBox<Map<dynamic, dynamic>>(_subscriptionDataBoxName);
      final subscriptionKeysToRemove = subscriptionBox.keys
          .where((key) {
            final sub = subscriptionBox.get(key);
            return sub != null && sub['userId'] == userId;
          })
          .toList();
      
      for (final key in subscriptionKeysToRemove) {
        await subscriptionBox.delete(key);
      }

      // Aqui seria a limpeza de favoritos e comentários conforme implementação

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error clearing user data: $e'));
    }
  }

  /// Obtém estatísticas de dados do usuário
  Future<Either<Exception, Map<String, int>>> getUserDataStats() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final stats = <String, int>{};

      // Contar configurações
      final appSettingsBox = await Hive.openBox<AppSettingsModel>(_appSettingsBoxName);
      stats['app_settings'] = appSettingsBox.values
          .where((settings) => settings.userId == userId)
          .length;

      // Contar subscriptions
      final subscriptionBox = await Hive.openBox<Map<dynamic, dynamic>>(_subscriptionDataBoxName);
      stats['subscription_data'] = subscriptionBox.values
          .where((sub) => sub['userId'] == userId)
          .length;

      // Aqui seria a contagem de favoritos e comentários conforme implementação
      stats['favoritos'] = 0; // Placeholder
      stats['comentarios'] = 0; // Placeholder

      return Right(stats);
    } catch (e) {
      return Left(Exception('Error getting user data stats: $e'));
    }
  }
}