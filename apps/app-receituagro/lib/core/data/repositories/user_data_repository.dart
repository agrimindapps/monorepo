import 'package:core/core.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// FIXED (P0.1): Changed from core/services/ to core/utils/
// DEPRECATED: import '../../../core/utils/box_manager.dart';

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
  // Specialized repositories for delegation (Dependency Injection)
  final IFavoritosRepository _favoritosRepository;
  final IComentariosRepository _comentariosRepository;

  UserDataRepository({
    IFavoritosRepository? favoritosRepository,
    IComentariosRepository? comentariosRepository,
  }) : _favoritosRepository =
           favoritosRepository ?? GetIt.instance<IFavoritosRepository>(),
       _comentariosRepository =
           comentariosRepository ?? GetIt.instance<IComentariosRepository>();

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
  /// DEPRECATED: Hive removed - Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, AppSettingsModel?>> getAppSettings() async {
    return Left(Exception('Method deprecated: Hive support removed. Use Firebase or Drift instead.'));
  }

  /// Salva configurações do app para o usuário atual
  /// DEPRECATED: Hive removed - Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, void>> saveAppSettings(
    AppSettingsModel settings,
  ) async {
    return Left(Exception('Method deprecated: Hive support removed. Use Firebase or Drift instead.'));
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
  /// DEPRECATED: Hive removed - Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, SubscriptionEntity?>> getSubscriptionData() async {
    return Left(Exception('Method deprecated: Hive support removed. Use Firebase or Drift instead.'));
  }

  /// Salva dados de subscription para o usuário atual
  /// DEPRECATED: Hive removed - Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, void>> saveSubscriptionData(
    SubscriptionEntity subscription,
  ) async {
    return Left(Exception('Method deprecated: Hive support removed. Use Firebase or Drift instead.'));
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
      final favoritos = await _favoritosRepository.getByTipo(
        TipoFavorito.defensivo,
      );

      // Converte entities para models
      final models = favoritos
          .whereType<FavoritoDefensivoEntity>()
          .map(
            (entity) => FavoritoDefensivoModel(
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
            ),
          )
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
      final success =
          await (_favoritosRepository as dynamic).addFavorito(
                TipoFavorito.defensivo,
                favorito.idReg,
              )
              as bool;

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
      final success =
          await (_favoritosRepository as dynamic).removeFavorito(
                TipoFavorito.defensivo,
                favoritoId.toString(),
              )
              as bool;

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
      final models = entities
          .map(
            (entity) => ComentarioModel(
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
            ),
          )
          .toList();

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
        final unsyncedFavoritos = favoritos
            .where((f) => !f.synchronized)
            .toList();
        if (unsyncedFavoritos.isNotEmpty) {
          unsynchronizedData['favoritos'] = unsyncedFavoritos;
        }
      });
      final comentariosResult = await getComentarios();
      comentariosResult.fold((error) => null, (comentarios) {
        final unsyncedComentarios = comentarios
            .where((c) => !c.synchronized)
            .toList();
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
  /// DEPRECATED: Hive removed - Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, void>> clearUserData() async {
    return Left(Exception('Method deprecated: Hive support removed. Use Firebase or Drift instead.'));
  }

  /// Obtém estatísticas de dados do usuário
  /// DEPRECATED: Hive removed - Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, Map<String, int>>> getUserDataStats() async {
    return Left(Exception('Method deprecated: Hive support removed. Use Firebase or Drift instead.'));
  }
}
