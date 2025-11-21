import 'package:core/core.dart';

import '../../domain/entities/favorito_entity.dart';
import '../services/favoritos_service.dart';

/// Repositório simplificado para Favoritos usando o FavoritosService consolidado
/// Princípio: Simplicidade e redução de complexidade desnecessária
class FavoritosRepositorySimplified implements IFavoritosRepository {
  final FavoritosService _service;

  const FavoritosRepositorySimplified({required FavoritosService service})
    : _service = service;

  @override
  Future<Either<Failure, List<FavoritoEntity>>> getAll() async {
    try {
      final futures = await Future.wait([
        _getByTipoWithEither(TipoFavorito.defensivo),
        _getByTipoWithEither(TipoFavorito.praga),
        _getByTipoWithEither(TipoFavorito.diagnostico),
        _getByTipoWithEither(TipoFavorito.cultura),
      ]);

      final List<FavoritoEntity> allFavoritos = [];
      for (final typeResult in futures) {
        typeResult.fold(
          (failure) => null,
          (typeList) => allFavoritos.addAll(typeList),
        );
      }
      allFavoritos.sort((a, b) => a.nomeDisplay.compareTo(b.nomeDisplay));

      return Right(allFavoritos);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar todos os favoritos: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<FavoritoEntity>>> _getByTipoWithEither(
    String tipo,
  ) async {
    try {
      final ids = await _service.getFavoriteIds(tipo);
      final favoritos = <FavoritoEntity>[];

      for (final id in ids) {
        final entity = await _getEntityById(tipo, id);
        if (entity != null) {
          favoritos.add(entity);
        }
      }

      return Right(favoritos);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar favoritos por tipo: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<FavoritoEntity>>> getByTipo(String tipo) async {
    try {
      final ids = await _service.getFavoriteIds(tipo);
      final favoritos = <FavoritoEntity>[];

      for (final id in ids) {
        final entity = await _getEntityById(tipo, id);
        if (entity != null) {
          favoritos.add(entity);
        }
      }

      return Right(favoritos);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar favoritos por tipo: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FavoritosStats>> getStats() async {
    try {
      final stats = await _service.getStats();
      return Right(stats);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar estatísticas de favoritos: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorito(String tipo, String id) async {
    try {
      final result = await _service.isFavoriteId(tipo, id);
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao verificar favorito: ${e.toString()}'),
      );
    }
  }

  /// Implementação genérica: adiciona qualquer tipo de FavoritoEntity
  /// Novo padrão: substitui addDefensivo, addPraga, addDiagnostico, addCultura
  @override
  Future<Either<Failure, bool>> addFavorito(FavoritoEntity favorito) async {
    try {
      final result = await _service.addFavoriteId(favorito.tipo, favorito.id);
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao adicionar favorito: ${e.toString()}'),
      );
    }
  }

  /// Implementação: remove favorito genérico
  /// Novo padrão: substitui removeDefensivo, removePraga, removeDiagnostico, removeCultura
  @override
  Future<Either<Failure, bool>> removeFavorito(String tipo, String id) async {
    try {
      final result = await _service.removeFavoriteId(tipo, id);
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao remover favorito: ${e.toString()}'),
      );
    }
  }

  /// Implementação: alterna favorito genérico
  @override
  Future<Either<Failure, bool>> toggleFavorito(String tipo, String id) async {
    try {
      final isFavResult = await isFavorito(tipo, id);

      final isFav = isFavResult.fold(
        (failure) => throw Exception(failure.message),
        (result) => result,
      );

      if (isFav) {
        return removeFavorito(tipo, id);
      } else {
        return _addFavoritoSimples(tipo, id);
      }
    } catch (e) {
      return Left(
        CacheFailure('Erro ao alternar favorito: ${e.toString()}'),
      );
    }
  }

  /// Helper privado: adiciona favorito (padrão antigo, mantido para compatibilidade)
  Future<Either<Failure, bool>> _addFavoritoSimples(
    String tipo,
    String id,
  ) async {
    try {
      final result = await _service.addFavoriteId(tipo, id);
      return Right(result);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao adicionar favorito: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<FavoritoEntity>>> search(String query) async {
    try {
      final allResult = await getAll();

      return allResult.fold(
        (failure) => Left(failure),
        (allFavoritos) {
          final queryLower = query.toLowerCase();

          return Right(allFavoritos.where((favorito) {
            return favorito.nomeDisplay.toLowerCase().contains(queryLower);
          }).toList());
        },
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar favoritos: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> clearFavorites(String tipo) async {
    try {
      await _service.clearFavorites(tipo);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao limpar favoritos: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> clearAllFavorites() async {
    try {
      await _service.clearAllFavorites();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao limpar todos os favoritos: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> syncFavorites() async {
    try {
      await _service.syncFavorites();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao sincronizar favoritos: ${e.toString()}'),
      );
    }
  }

  /// Helper privado para obter entidade por ID
  Future<FavoritoEntity?> _getEntityById(String tipo, String id) async {
    try {
      final data = await _service.resolveItemData(tipo, id);
      if (data != null) {
        return _service.createEntity(tipo: tipo, id: id, data: data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtém defensivos favoritos
  Future<Either<Failure, List<FavoritoDefensivoEntity>>> getDefensivos() async {
    try {
      final result = await getByTipo(TipoFavorito.defensivo);
      return result.fold(
        (failure) => Left(failure),
        (favoritos) => Right(favoritos.whereType<FavoritoDefensivoEntity>().toList()),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter defensivos favoritos: ${e.toString()}'),
      );
    }
  }

  /// Obtém pragas favoritas
  Future<Either<Failure, List<FavoritoPragaEntity>>> getPragas() async {
    try {
      final result = await getByTipo(TipoFavorito.praga);
      return result.fold(
        (failure) => Left(failure),
        (favoritos) => Right(favoritos.whereType<FavoritoPragaEntity>().toList()),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter pragas favoritas: ${e.toString()}'),
      );
    }
  }

  /// Obtém diagnósticos favoritos
  Future<Either<Failure, List<FavoritoDiagnosticoEntity>>> getDiagnosticos() async {
    try {
      final result = await getByTipo(TipoFavorito.diagnostico);
      return result.fold(
        (failure) => Left(failure),
        (favoritos) => Right(favoritos.whereType<FavoritoDiagnosticoEntity>().toList()),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter diagnósticos favoritos: ${e.toString()}'),
      );
    }
  }

  /// Obtém culturas favoritas
  Future<Either<Failure, List<FavoritoCulturaEntity>>> getCulturas() async {
    try {
      final result = await getByTipo(TipoFavorito.cultura);
      return result.fold(
        (failure) => Left(failure),
        (favoritos) => Right(favoritos.whereType<FavoritoCulturaEntity>().toList()),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter culturas favoritas: ${e.toString()}'),
      );
    }
  }

  /// Verifica se defensivo é favorito
  Future<Either<Failure, bool>> isDefensivoFavorito(String id) async {
    return isFavorito(TipoFavorito.defensivo, id);
  }

  /// Verifica se praga é favorita
  Future<Either<Failure, bool>> isPragaFavorito(String id) async {
    return isFavorito(TipoFavorito.praga, id);
  }

  /// Verifica se diagnóstico é favorito
  Future<Either<Failure, bool>> isDiagnosticoFavorito(String id) async {
    return isFavorito(TipoFavorito.diagnostico, id);
  }

  /// Verifica se cultura é favorita
  Future<Either<Failure, bool>> isCulturaFavorito(String id) async {
    return isFavorito(TipoFavorito.cultura, id);
  }

  /// Adiciona defensivo aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<Either<Failure, bool>> addDefensivo(String id) async {
    return _addFavoritoSimples(TipoFavorito.defensivo, id);
  }

  /// Adiciona praga aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<Either<Failure, bool>> addPraga(String id) async {
    return _addFavoritoSimples(TipoFavorito.praga, id);
  }

  /// Adiciona diagnóstico aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<Either<Failure, bool>> addDiagnostico(String id) async {
    return _addFavoritoSimples(TipoFavorito.diagnostico, id);
  }

  /// Adiciona cultura aos favoritos
  /// @Deprecated Use `addFavorito(FavoritoEntity)` em vez disso
  Future<Either<Failure, bool>> addCultura(String id) async {
    return _addFavoritoSimples(TipoFavorito.cultura, id);
  }

  /// Remove defensivo dos favoritos
  Future<Either<Failure, bool>> removeDefensivo(String id) async {
    return removeFavorito(TipoFavorito.defensivo, id);
  }

  /// Remove praga dos favoritos
  Future<Either<Failure, bool>> removePraga(String id) async {
    return removeFavorito(TipoFavorito.praga, id);
  }

  /// Remove diagnóstico dos favoritos
  Future<Either<Failure, bool>> removeDiagnostico(String id) async {
    return removeFavorito(TipoFavorito.diagnostico, id);
  }

  /// Remove cultura dos favoritos
  Future<Either<Failure, bool>> removeCultura(String id) async {
    return removeFavorito(TipoFavorito.cultura, id);
  }
}
