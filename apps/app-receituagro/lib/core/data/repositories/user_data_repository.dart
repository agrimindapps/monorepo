import 'package:core/core.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// FIXED (P0.1): Changed from core/services/ to core/utils/
// DEPRECATED: import '../../../core/utils/box_manager.dart';

import '../../../features/comentarios/data/comentario_model.dart';
import '../../../features/comentarios/domain/entities/comentario_entity.dart';
import '../../../features/comentarios/domain/repositories/i_comentarios_read_repository.dart';
import '../../../features/comentarios/domain/repositories/i_comentarios_write_repository.dart';
import '../../../features/favoritos/data/favorito_defensivo_model.dart';
import '../../../features/favoritos/domain/entities/favorito_entity.dart';
import '../../../features/favoritos/domain/repositories/i_favoritos_repository.dart';

/// Repository para gerenciar dados específicos do usuário com sincronização
///
/// Delegation Pattern: Delega operações especializadas para repositórios dedicados
/// - Favoritos → IFavoritosRepository (FavoritosRepositorySimplified)
/// - Comentários → IComentariosRepository (ComentariosRepositoryImpl)
class UserDataRepository {
  // Specialized repositories for delegation (Dependency Injection)
  final IFavoritosRepository _favoritosRepository;
  final IComentariosReadRepository _comentariosReadRepository;
  final IComentariosWriteRepository _comentariosWriteRepository;

  UserDataRepository({
    required IFavoritosRepository favoritosRepository,
    required IComentariosReadRepository comentariosReadRepository,
    required IComentariosWriteRepository comentariosWriteRepository,
  }) : _favoritosRepository = favoritosRepository,
       _comentariosReadRepository = comentariosReadRepository,
       _comentariosWriteRepository = comentariosWriteRepository;

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

  // ========================================================================
  // DEPRECATED METHODS - Removed
  // These methods have been replaced by dedicated Drift repositories:
  // - App Settings → Use AppSettingsRepository (Drift-based)
  // - Subscription Data → Use SubscriptionRepository (Drift + Firebase)
  // ========================================================================

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
      final result = await _favoritosRepository.getByTipo(
        TipoFavorito.defensivo,
      );

      // Unwrap Either and convert entities to models
      return result.fold(
        (failure) => Left(Exception('Failed to get favoritos: $failure')),
        (favoritos) {
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
        },
      );
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
      final entities = await _comentariosReadRepository.getAllComentarios();

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
      await _comentariosWriteRepository.addComentario(entity);

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
      await _comentariosWriteRepository.deleteComentario(comentarioId);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error removing comentario: $e'));
    }
  }

  // ========================================================================
  // SYNC OPERATIONS
  // ========================================================================

  /// Obtém todos os itens não sincronizados do usuário
  ///
  /// Note: AppSettings and Subscription are now managed by dedicated repositories.
  /// This method only returns unsynchronized favoritos and comentarios.
  Future<Either<Exception, Map<String, List<dynamic>>>>
  getUnsynchronizedData() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return Left(Exception('No user logged in'));
      }

      final unsynchronizedData = <String, List<dynamic>>{};

      // AppSettings and Subscription sync are handled by dedicated repositories
      // Only track Favoritos and Comentarios here

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
  /// Note: All sync operations are now managed by dedicated services:
  /// - AppSettings → AppSettingsRepository
  /// - Subscription → SubscriptionRepository
  /// - Favoritos → FavoritosSyncService
  /// - Comentarios → ComentariosSyncService
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
          // AppSettings sync is managed by AppSettingsRepository
          return const Right(null);

        case 'subscription_data':
          // Subscription sync is managed by SubscriptionRepository
          return const Right(null);

        case 'favoritos':
          // Favoritos sync is managed by FavoritosSyncService
          return const Right(null);

        case 'comentarios':
          // Comentarios sync is managed by ComentariosSyncService
          return const Right(null);

        default:
          return Left(Exception('Unknown item type: $type'));
      }
    } catch (e) {
      return Left(Exception('Error marking item as synchronized: $e'));
    }
  }

  /// DEPRECATED: Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, void>> clearUserData() async {
    return Left(Exception('Method deprecated. Use Firebase or Drift instead.'));
  }

  /// Obtém estatísticas de dados do usuário
  /// DEPRECATED: Use Firebase or Drift for persistence
  @Deprecated('Use Firebase or Drift repositories instead')
  Future<Either<Exception, Map<String, int>>> getUserDataStats() async {
    return Left(Exception('Method deprecated. Use Firebase or Drift instead.'));
  }
}
