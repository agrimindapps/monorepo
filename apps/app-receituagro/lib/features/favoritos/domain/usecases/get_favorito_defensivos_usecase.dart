import 'package:core/core.dart' hide Column;

import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';

/// Use Case para obter lista de defensivos favoritos
/// Segue padrão `Either<Failure, Success>` do core package
///
/// @Deprecated Substituído por `IFavoritosRepository.getByTipo()` genérico
///
/// **Migração:** Use o repositório diretamente ou via notifier:
/// ```dart
/// // Antes (usecase específico):
/// final result = await getFavoritoDefensivosUseCase();
///
/// // Depois (repositório genérico):
/// final defensivos = await repository.getByTipo(TipoFavorito.defensivo);
///
/// // Ou via Riverpod notifier:
/// final favoritos = ref.watch(favoritosNotifierProvider);
/// final defensivos = favoritos.getFavoritosByTipo<FavoritoDefensivoEntity>(
///   TipoFavorito.defensivo
/// );
/// ```
///
/// **Benefício:** Menos boilerplate, lógica centralizada no repositório
@deprecated
@injectable
class GetFavoritoDefensivosUseCase {
  final IFavoritosDefensivosRepository _repository;

  const GetFavoritoDefensivosUseCase(this._repository);

  /// Executa o caso de uso para obter defensivos favoritos
  /// Retorna `Either<Failure, List<FavoritoDefensivoEntity>>`
  Future<Either<Failure, List<FavoritoDefensivoEntity>>> call() async {
    try {
      final defensivosFavoritos = await _repository.getDefensivos();

      return Right(defensivosFavoritos);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter defensivos favoritos: ${e.toString()}'),
      );
    }
  }
}
