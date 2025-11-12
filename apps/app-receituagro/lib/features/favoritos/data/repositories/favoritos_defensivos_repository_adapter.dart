import 'package:core/core.dart' hide Column;

import '../../domain/entities/favorito_entity.dart';
import '../../domain/repositories/i_favoritos_repository.dart';

/// Adapter to bridge IFavoritosDefensivosRepository to IFavoritosRepository
///
/// This adapter implements the segregated interface (ISP) by delegating
/// to the unified repository implementation.
@LazySingleton(as: IFavoritosDefensivosRepository)
class FavoritosDefensivosRepositoryAdapter
    implements IFavoritosDefensivosRepository {
  final IFavoritosRepository _repository;

  const FavoritosDefensivosRepositoryAdapter({
    required IFavoritosRepository repository,
  }) : _repository = repository;

  @override
  Future<List<FavoritoDefensivoEntity>> getDefensivos() async {
    final favoritos = await _repository.getByTipo(TipoFavorito.defensivo);
    return favoritos.whereType<FavoritoDefensivoEntity>().toList();
  }

  @override
  Future<bool> addDefensivo(String defensivoId) async {
    return await _repository.addFavorito(
      FavoritoDefensivoEntity(
        id: defensivoId,
        nomeComum: '',
        ingredienteAtivo: '',
      ),
    );
  }

  @override
  Future<bool> removeDefensivo(String defensivoId) async {
    return await _repository.removeFavorito(
      TipoFavorito.defensivo,
      defensivoId,
    );
  }

  @override
  Future<bool> isDefensivoFavorito(String defensivoId) async {
    return await _repository.isFavorito(TipoFavorito.defensivo, defensivoId);
  }
}
