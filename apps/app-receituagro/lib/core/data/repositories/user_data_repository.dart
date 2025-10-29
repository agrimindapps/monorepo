import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// FIXED (P0.1): Changed from core/services/ to core/utils/
import '../../../core/utils/hive_box_manager.dart';

import '../../../features/comentarios/data/comentario_model.dart';
import '../../../features/comentarios/domain/entities/comentario_entity.dart';
import '../../../features/comentarios/domain/repositories/i_comentarios_repository.dart';
import '../../../features/favoritos/data/favorito_defensivo_model.dart';
import '../../../features/favoritos/domain/entities/favorito_entity.dart';
import '../../../features/favoritos/domain/repositories/i_favoritos_repository.dart';
import '../models/app_settings_model.dart';

/// Repository para gerenciar dados específicos do usuário com sincronização
///
/// Delegation Pattern: Delega operações especializadas para repositórios dedicados
/// - Favoritos → IFavoritosRepository (FavoritosRepositorySimplified)
/// - Comentários → IComentariosRepository (ComentariosRepositoryImpl)
class UserDataRepository {
  static const String _appSettingsBoxName = 'app_settings';
  static const String _subscriptionDataBoxName = 'subscription_data';

  // FIXED (P0.3): Inject IHiveManager to use HiveBoxManager pattern
  final IHiveManager _hiveManager;

  // Specialized repositories for delegation (Dependency Injection)
  final IFavoritosRepository _favoritosRepository;
  final IComentariosRepository _comentariosRepository;

  UserDataRepository({
    IHiveManager? hiveManager,
    IFavoritosRepository? favoritosRepository,
    IComentariosRepository? comentariosRepository,
  })  : _hiveManager = hiveManager ?? GetIt.instance<IHiveManager>(),
        _favoritosRepository = favoritosRepository ?? GetIt.instance<IFavoritosRepository>(),
        _comentariosRepository = comentariosRepository ?? GetIt.instance<IComentariosRepository>();

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

  /// Obtém configurações do app para o usuário atual
  Future<Either<Exception, AppSettingsModel?>> getAppSettings() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // FIXED (P0.3): Use HiveBoxManager.withBox with correct signature
      final result = await HiveBoxManager.withBox<AppSettingsModel, AppSettingsModel?>(
        hiveManager: _hiveManager,
        boxName: _appSettingsBoxName,
        operation: (box) async {
          return box.values
              .where((settings) => settings.userId == userId)
              .firstOrNull;
        },
      );

      return result.fold(
        (failure) => Left(Exception('Error getting app settings: $failure')),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(Exception('Error getting app settings: $e'));
    }
  }

  /// Salva configurações do app para o usuário atual
  Future<Either<Exception, void>> saveAppSettings(
    AppSettingsModel settings,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // FIXED (P0.3): Use HiveBoxManager.withBox instead of direct Hive.openBox()
      final result = await HiveBoxManager.withBox<AppSettingsModel, void>(
        hiveManager: _hiveManager,
        boxName: _appSettingsBoxName,
        operation: (box) async {
          final existingKey = box.keys.firstWhere(
            (key) => box.get(key)?.userId == userId,
            orElse: () => null,
          );
          final updatedSettings = settings.copyWith(
            userId: userId,
            sync_updatedAt: DateTime.now(),
            sync_synchronized: false, // Marca como não sincronizado
          );
          if (existingKey != null) {
            await box.put(existingKey, updatedSettings);
          } else {
            await box.add(updatedSettings);
          }
        },
      );

      return result.fold(
        (failure) => Left(Exception('Error saving app settings: $failure')),
        (_) => const Right(null),
      );
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
        sync_createdAt: DateTime.now(),
        sync_synchronized: false,
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

  /// Obtém dados de subscription para o usuário atual
  Future<Either<Exception, SubscriptionEntity?>> getSubscriptionData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // FIXED (P0.3): Use HiveBoxManager.withBox instead of direct Hive.openBox()
      final result = await HiveBoxManager.withBox<Map<dynamic, dynamic>, Map<dynamic, dynamic>?>(
        hiveManager: _hiveManager,
        boxName: _subscriptionDataBoxName,
        operation: (box) async {
          return box.values.where((sub) => sub['userId'] == userId).firstOrNull;
        },
      );

      return result.fold(
        (failure) => Left(Exception('Error getting subscription data: $failure')),
        (subscriptionMap) {
          if (subscriptionMap == null) {
            return const Right(null);
          }

          try {
            final entity = SubscriptionEntity.fromFirebaseMap(
              Map<String, dynamic>.from(subscriptionMap),
            );
            return Right(entity);
          } catch (e) {
            return Left(Exception('Error parsing subscription data: $e'));
          }
        },
      );
    } catch (e) {
      return Left(Exception('Error getting subscription data: $e'));
    }
  }

  /// Salva dados de subscription para o usuário atual
  Future<Either<Exception, void>> saveSubscriptionData(
    SubscriptionEntity subscription,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // FIXED (P0.3): Use HiveBoxManager.withBox instead of direct Hive.openBox()
      final result = await HiveBoxManager.withBox<Map<dynamic, dynamic>, void>(
        hiveManager: _hiveManager,
        boxName: _subscriptionDataBoxName,
        operation: (box) async {
          final existingKey = box.keys.firstWhere((key) {
            final sub = box.get(key);
            return sub != null && sub['userId'] == userId;
          }, orElse: () => null);
          final updatedSubscription = subscription.copyWith(
            userId: userId,
            updatedAt: DateTime.now(),
            isDirty: true, // Marca como não sincronizado
          );
          final subscriptionMap = updatedSubscription.toFirebaseMap();
          if (existingKey != null) {
            await box.put(existingKey, subscriptionMap);
          } else {
            await box.add(subscriptionMap);
          }
        },
      );

      return result.fold(
        (failure) => Left(Exception('Error saving subscription data: $failure')),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(Exception('Error saving subscription data: $e'));
    }
  }

  // ========================================================================
  // FAVORITOS - Delegation to IFavoritosRepository
  // ========================================================================

  /// Obtém favoritos do usuário atual (APENAS defensivos)
  ///
  /// DELEGATION: Delega para IFavoritosRepository.getByTipo('defensivo')
  /// Converte FavoritoDefensivoEntity → FavoritoDefensivoModel para compatibilidade
  Future<Either<Exception, List<FavoritoDefensivoModel>>> getFavoritos() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Delega para FavoritosRepository
      final favoritos = await _favoritosRepository.getByTipo(TipoFavorito.defensivo);

      // Converte entities para models
      final models = favoritos
          .whereType<FavoritoDefensivoEntity>()
          .map((entity) => FavoritoDefensivoModel(
                id: int.tryParse(entity.id) ?? 0,
                idReg: entity.id,
                line1: entity.line1,
                line2: entity.line2,
                nomeComum: entity.nomeComum,
                ingredienteAtivo: entity.ingredienteAtivo,
                fabricante: entity.fabricante,
                dataCriacao: entity.adicionadoEm ?? DateTime.now(),
                userId: userId,
                synchronized: false,
              ))
          .toList();

      return Right(models);
    } catch (e) {
      return Left(Exception('Error getting favoritos: $e'));
    }
  }

  /// Salva favorito para o usuário atual
  ///
  /// DELEGATION: Delega para IFavoritosRepository.addFavorito()
  /// Nota: FavoritoDefensivoModel contém apenas display data, não precisa persistir tudo
  Future<Either<Exception, void>> saveFavorito(
    FavoritoDefensivoModel favorito,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Delega para FavoritosRepository (salva apenas o ID)
      // O repository já cuida de verificar usuário e sincronizar
      final success = await (_favoritosRepository as dynamic).addFavorito(
        TipoFavorito.defensivo,
        favorito.idReg,
      ) as bool;

      if (success == false) {
        return Left(Exception('Failed to save favorito'));
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error saving favorito: $e'));
    }
  }

  /// Remove favorito do usuário atual
  ///
  /// DELEGATION: Delega para IFavoritosRepository.removeFavorito()
  Future<Either<Exception, void>> removeFavorito(int favoritoId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Delega para FavoritosRepository
      final success = await (_favoritosRepository as dynamic).removeFavorito(
        TipoFavorito.defensivo,
        favoritoId.toString(),
      ) as bool;

      if (success == false) {
        return Left(Exception('Failed to remove favorito'));
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error removing favorito: $e'));
    }
  }

  // ========================================================================
  // COMENTÁRIOS - Delegation to IComentariosRepository
  // ========================================================================

  /// Obtém comentários do usuário atual
  ///
  /// DELEGATION: Delega para IComentariosRepository.getAllComentarios()
  /// Converte ComentarioEntity → ComentarioModel para compatibilidade
  Future<Either<Exception, List<ComentarioModel>>> getComentarios() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Delega para ComentariosRepository
      final entities = await _comentariosRepository.getAllComentarios();

      // Converte entities para models
      final models = entities.map((entity) => ComentarioModel(
            id: entity.id,
            idReg: entity.idReg,
            titulo: entity.titulo,
            conteudo: entity.conteudo,
            ferramenta: entity.ferramenta,
            pkIdentificador: entity.pkIdentificador,
            status: entity.status,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            userId: userId,
            synchronized: false,
          )).toList();

      return Right(models);
    } catch (e) {
      return Left(Exception('Error getting comentarios: $e'));
    }
  }

  /// Salva comentário para o usuário atual
  ///
  /// DELEGATION: Delega para IComentariosRepository.addComentario()
  Future<Either<Exception, void>> saveComentario(
    ComentarioModel comentario,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Converte model para entity
      final entity = ComentarioEntity(
        id: comentario.id,
        idReg: comentario.idReg,
        titulo: comentario.titulo,
        conteudo: comentario.conteudo,
        ferramenta: comentario.ferramenta,
        pkIdentificador: comentario.pkIdentificador,
        status: comentario.status,
        createdAt: comentario.createdAt,
        updatedAt: DateTime.now(),
      );

      // Delega para ComentariosRepository
      await _comentariosRepository.addComentario(entity);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error saving comentario: $e'));
    }
  }

  /// Remove comentário do usuário atual
  ///
  /// DELEGATION: Delega para IComentariosRepository.deleteComentario()
  Future<Either<Exception, void>> removeComentario(String comentarioId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      // Delega para ComentariosRepository (soft delete)
      await _comentariosRepository.deleteComentario(comentarioId);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error removing comentario: $e'));
    }
  }

  // ========================================================================
  // SYNC OPERATIONS
  // ========================================================================

  /// Obtém todos os itens não sincronizados do usuário
  Future<Either<Exception, Map<String, List<dynamic>>>>
  getUnsynchronizedData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final unsynchronizedData = <String, List<dynamic>>{};
      final settingsResult = await getAppSettings();
      settingsResult.fold((error) => null, (settings) {
        if (settings != null && !settings.sync_synchronized) {
          unsynchronizedData['app_settings'] = [settings];
        }
      });
      final subscriptionResult = await getSubscriptionData();
      subscriptionResult.fold((error) => null, (subscription) {
        if (subscription != null && subscription.isDirty) {
          unsynchronizedData['subscription_data'] = [subscription];
        }
      });
      final favoritosResult = await getFavoritos();
      favoritosResult.fold((error) => null, (favoritos) {
        final unsyncedFavoritos =
            favoritos.where((f) => !f.synchronized).toList();
        if (unsyncedFavoritos.isNotEmpty) {
          unsynchronizedData['favoritos'] = unsyncedFavoritos;
        }
      });
      final comentariosResult = await getComentarios();
      comentariosResult.fold((error) => null, (comentarios) {
        final unsyncedComentarios =
            comentarios.where((c) => !c.synchronized).toList();
        if (unsyncedComentarios.isNotEmpty) {
          unsynchronizedData['comentarios'] = unsyncedComentarios;
        }
      });

      return Right(unsynchronizedData);
    } catch (e) {
      return Left(Exception('Error getting unsynchronized data: $e'));
    }
  }

  /// Marca item como sincronizado
  ///
  /// Nota: Favoritos e Comentários gerenciam sua própria sincronização
  /// via FavoritosSyncService e ComentariosSyncService
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
          return settingsResult.fold((error) => Left(error), (settings) async {
            if (settings != null) {
              final syncedSettings = settings.markAsSynchronized();
              return await saveAppSettings(syncedSettings);
            }
            return Left(Exception('Settings not found'));
          });

        case 'subscription_data':
          final subscriptionResult = await getSubscriptionData();
          return subscriptionResult.fold((error) => Left(error), (
            subscription,
          ) async {
            if (subscription != null) {
              final syncedSubscription = subscription.markAsSynced();
              return await saveSubscriptionData(syncedSubscription);
            }
            return Left(Exception('Subscription not found'));
          });

        case 'favoritos':
          // Favoritos sincronização é gerenciada por FavoritosSyncService
          return const Right(null);

        case 'comentarios':
          // Comentarios sincronização é gerenciada por ComentariosSyncService
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

      // FIXED (P0.3): Use HiveBoxManager.withMultipleBoxes with correct signature
      final result = await HiveBoxManager.withMultipleBoxes<void>(
        hiveManager: _hiveManager,
        boxNames: [_appSettingsBoxName, _subscriptionDataBoxName],
        operation: (boxes) async {
          final appSettingsBox = boxes[_appSettingsBoxName] as Box<dynamic>;
          final subscriptionBox = boxes[_subscriptionDataBoxName] as Box<dynamic>;

          final settingsKeysToRemove = appSettingsBox.keys.where((key) {
            final settings = appSettingsBox.get(key);
            return settings is AppSettingsModel && settings.userId == userId;
          }).toList();

          for (final key in settingsKeysToRemove) {
            await appSettingsBox.delete(key);
          }

          final subscriptionKeysToRemove = subscriptionBox.keys.where((key) {
            final sub = subscriptionBox.get(key);
            return sub is Map && sub['userId'] == userId;
          }).toList();

          for (final key in subscriptionKeysToRemove) {
            await subscriptionBox.delete(key);
          }
        },
      );

      return result.fold(
        (failure) => Left(Exception('Error clearing user data: $failure')),
        (_) => const Right(null),
      );
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

      // FIXED (P0.3): Use HiveBoxManager.withMultipleBoxes to avoid multiple open/close cycles
      final result = await HiveBoxManager.withMultipleBoxes<Map<String, int>>(
        hiveManager: _hiveManager,
        boxNames: [_appSettingsBoxName, _subscriptionDataBoxName],
        operation: (boxes) async {
          final appSettingsBox = boxes[_appSettingsBoxName] as Box<dynamic>;
          final subscriptionBox = boxes[_subscriptionDataBoxName] as Box<dynamic>;

          final stats = <String, int>{};

          stats['app_settings'] = appSettingsBox.values
              .whereType<AppSettingsModel>()
              .where((settings) => settings.userId == userId)
              .length;

          stats['subscription_data'] = subscriptionBox.values
              .whereType<Map<dynamic, dynamic>>()
              .where((sub) => sub['userId'] == userId)
              .length;

          // Delegate to specialized repositories for accurate counts
          try {
            final favoritosResult = await getFavoritos();
            favoritosResult.fold(
              (error) => stats['favoritos'] = 0,
              (favoritos) => stats['favoritos'] = favoritos.length,
            );
          } catch (_) {
            stats['favoritos'] = 0;
          }

          try {
            final comentariosResult = await getComentarios();
            comentariosResult.fold(
              (error) => stats['comentarios'] = 0,
              (comentarios) => stats['comentarios'] = comentarios.length,
            );
          } catch (_) {
            stats['comentarios'] = 0;
          }

          return stats;
        },
      );

      return result.fold(
        (failure) => Left(Exception('Error getting user data stats: $failure')),
        (stats) => Right(stats),
      );
    } catch (e) {
      return Left(Exception('Error getting user data stats: $e'));
    }
  }
}
