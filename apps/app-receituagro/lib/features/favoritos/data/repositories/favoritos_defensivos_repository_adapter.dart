import 'package:core/core.dart';

import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Adapter to bridge IFavoritosDefensivosRepository to IFavoritosRepository
///
/// This adapter implements the segregated interface (ISP) by delegating
/// to the unified repository implementation.

class FavoritosDefensivosRepositoryAdapter
    implements IFavoritosDefensivosRepository {
  final IFavoritosRepository _repository;

  const FavoritosDefensivosRepositoryAdapter({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  @override
  Future<List<FavoritoDefensivoEntity>> getDefensivos() async {
    final favoritosResult = await _repository.getByTipo(TipoFavorito.defensivo);
    return favoritosResult.fold(
      (failure) => throw Exception(failure.message),
      (favoritos) => favoritos.whereType<FavoritoDefensivoEntity>().toList(),
    );
  }

  @override
  Future<bool> addDefensivo(String defensivoId) async {
    final result = await _repository.addFavorito(
      FavoritoDefensivoEntity(
        id: defensivoId,
        nomeComum: '',
        ingredienteAtivo: '',
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  }

  @override
  Future<bool> removeDefensivo(String defensivoId) async {
    final result = await _repository.removeFavorito(
      TipoFavorito.defensivo,
      defensivoId,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  }

  @override
  Future<bool> isDefensivoFavorito(String defensivoId) async {
    final result = await _repository.isFavorito(TipoFavorito.defensivo, defensivoId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (isFavorite) => isFavorite,
    );
  }
}
