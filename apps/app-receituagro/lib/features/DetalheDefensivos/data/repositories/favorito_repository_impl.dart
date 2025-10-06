import 'package:core/core.dart';

import '../../../../core/data/repositories/favoritos_hive_repository.dart';
import '../../../../core/errors/failures.dart' as app_failures;
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/favorito_repository.dart';

/// Implementação do repositório de favoritos
///
/// Esta classe implementa o contrato definido no domain layer,
/// usando o FavoritosHiveRepository como fonte de dados
class FavoritoRepositoryImpl implements FavoritoRepository {
  const FavoritoRepositoryImpl(this._hiveRepository);

  final FavoritosHiveRepository _hiveRepository;

  @override
  ResultFuture<String> addFavorito(FavoritoEntity favorito) async {
    try {
      final itemData = {
        'nome': favorito.nome,
        'fabricante': favorito.fabricante,
        'cultura': favorito.cultura,
        'idReg': favorito.itemId,
        ...favorito.metadata,
      };

      final success = await _hiveRepository.addFavorito(
        favorito.tipo,
        favorito.itemId,
        itemData,
      );

      if (success) {
        return Right(favorito.id);
      } else {
        return const Left(
          app_failures.CacheFailure('Falha ao adicionar favorito'),
        );
      }
    } catch (e) {
      return Left(
        app_failures.CacheFailure(
          'Erro ao adicionar favorito: ${e.toString()}',
        ),
      );
    }
  }

  @override
  ResultFuture<void> removeFavorito(String itemId, String tipo) async {
    try {
      final success = await _hiveRepository.removeFavorito(tipo, itemId);

      if (success) {
        return const Right(null);
      } else {
        return const Left(
          app_failures.CacheFailure('Falha ao remover favorito'),
        );
      }
    } catch (e) {
      return Left(
        app_failures.CacheFailure('Erro ao remover favorito: ${e.toString()}'),
      );
    }
  }

  @override
  ResultFuture<bool> isFavorito(String itemId, String tipo) async {
    try {
      final isFavorited = await _hiveRepository.isFavorito(tipo, itemId);
      return Right(isFavorited);
    } catch (e) {
      return Left(
        app_failures.CacheFailure(
          'Erro ao verificar favorito: ${e.toString()}',
        ),
      );
    }
  }

  @override
  ResultFuture<List<FavoritoEntity>> getFavoritosByTipo(String tipo) async {
    try {
      final hiveFavoritos = await _hiveRepository.getFavoritosByTipoAsync(tipo);
      final favoritos = <FavoritoEntity>[];

      for (final hiveFavorito in hiveFavoritos) {
        final data = await _hiveRepository.getFavoritoDataAsync(
          tipo,
          hiveFavorito.itemId,
        );
        if (data != null) {
          favoritos.add(
            FavoritoEntity(
              id: hiveFavorito.objectId,
              itemId: hiveFavorito.itemId,
              tipo: hiveFavorito.tipo,
              nome: data['nome']?.toString() ?? '',
              fabricante: data['fabricante']?.toString(),
              cultura: data['cultura']?.toString(),
              metadata: data,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                hiveFavorito.createdAt,
              ),
            ),
          );
        }
      }

      return Right(favoritos);
    } catch (e) {
      return Left(
        app_failures.CacheFailure(
          'Erro ao buscar favoritos por tipo: ${e.toString()}',
        ),
      );
    }
  }

  @override
  ResultFuture<List<FavoritoEntity>> getAllFavoritos() async {
    try {
      final hiveFavoritos = await _hiveRepository.getAllAsync();
      final favoritos = <FavoritoEntity>[];

      for (final hiveFavorito in hiveFavoritos) {
        final data = await _hiveRepository.getFavoritoDataAsync(
          hiveFavorito.tipo,
          hiveFavorito.itemId,
        );
        if (data != null) {
          favoritos.add(
            FavoritoEntity(
              id: hiveFavorito.objectId,
              itemId: hiveFavorito.itemId,
              tipo: hiveFavorito.tipo,
              nome: data['nome']?.toString() ?? '',
              fabricante: data['fabricante']?.toString(),
              cultura: data['cultura']?.toString(),
              metadata: data,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                hiveFavorito.createdAt,
              ),
            ),
          );
        }
      }

      return Right(favoritos);
    } catch (e) {
      return Left(
        app_failures.CacheFailure(
          'Erro ao buscar todos os favoritos: ${e.toString()}',
        ),
      );
    }
  }

  @override
  ResultFuture<List<FavoritoEntity>> searchFavoritos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final allFavoritosResult = await getAllFavoritos();
      return allFavoritosResult.fold((failure) => Left(failure), (favoritos) {
        final filteredFavoritos =
            favoritos.where((favorito) {
              final lowerQuery = query.toLowerCase();
              return favorito.nome.toLowerCase().contains(lowerQuery) ||
                  (favorito.fabricante?.toLowerCase().contains(lowerQuery) ??
                      false) ||
                  (favorito.cultura?.toLowerCase().contains(lowerQuery) ??
                      false);
            }).toList();
        return Right(filteredFavoritos);
      });
    } catch (e) {
      return Left(
        app_failures.CacheFailure(
          'Erro ao pesquisar favoritos: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<List<FavoritoEntity>> watchFavoritos() async* {
    try {
      // Como não temos stream nativo, simulamos com refresh periódico
      while (true) {
        final favoritosResult = await getAllFavoritos();
        yield favoritosResult.fold(
          (failure) => <FavoritoEntity>[],
          (favoritos) => favoritos,
        );

        // Aguarda 5 segundos antes do próximo refresh
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      yield [];
    }
  }

  @override
  ResultFuture<int> countFavoritosByTipo(String tipo) async {
    try {
      final hiveFavoritos = await _hiveRepository.getFavoritosByTipoAsync(tipo);
      return Right(hiveFavoritos.length);
    } catch (e) {
      return Left(
        app_failures.CacheFailure('Erro ao contar favoritos: ${e.toString()}'),
      );
    }
  }

  @override
  ResultFuture<void> clearAllFavoritos() async {
    try {
      final stats = await _hiveRepository.getFavoritosStats();
      for (final tipo in stats.keys) {
        await _hiveRepository.clearFavoritosByTipo(tipo);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        app_failures.CacheFailure('Erro ao limpar favoritos: ${e.toString()}'),
      );
    }
  }
}
