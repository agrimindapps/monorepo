import 'package:core/core.dart' hide Column;

import '../repositories/i_favoritos_repository.dart';

/// UseCase genérico para remover qualquer tipo de favorito
/// Substitui os específicos (RemoveFavoritoDefensivoUseCase, RemoveFavoritoPragaUseCase, etc)
///
/// **Benefício:** Consolidação de 4+ usecases em 1 genérico reutilizável
@injectable
class RemoveFavoritoUseCase {
  final IFavoritosRepository _repository;

  const RemoveFavoritoUseCase(this._repository);

  /// Remove um favorito genérico
  ///
  /// **Parâmetros:**
  /// - `tipo`: Tipo de favorito (TipoFavorito.defensivo, .praga, .diagnostico, .cultura)
  /// - `id`: ID do item favorito
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// final result = await removeFavoritoUseCase(
  ///   tipo: TipoFavorito.defensivo,
  ///   id: '123',
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Erro: ${failure.message}'),
  ///   (success) => print('✓ Removido dos favoritos'),
  /// );
  /// ```
  ///
  /// **Tipos suportados:**
  /// - `TipoFavorito.defensivo`
  /// - `TipoFavorito.praga`
  /// - `TipoFavorito.diagnostico`
  /// - `TipoFavorito.cultura`
  Future<Either<Failure, bool>> call({
    required String tipo,
    required String id,
  }) async {
    try {
      // Validação de parâmetros
      if (tipo.isEmpty || id.isEmpty) {
        return Left(ValidationFailure('Tipo e ID são obrigatórios'));
      }

      // Verifica se existe nos favoritos
      final isFavorite = await _repository.isFavorito(tipo, id);
      if (!isFavorite) {
        return Left(NotFoundFailure('Favorito não encontrado: $tipo/$id'));
      }

      // Tenta remover dos favoritos
      final result = await _repository.removeFavorito(tipo, id);

      if (!result) {
        return Left(CacheFailure('Falha ao remover $tipo dos favoritos'));
      }

      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover favorito: ${e.toString()}'));
    }
  }
}
