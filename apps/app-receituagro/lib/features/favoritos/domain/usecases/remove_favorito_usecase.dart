import 'package:core/core.dart';

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
    // Validação de parâmetros
    if (tipo.isEmpty || id.isEmpty) {
      return Left<Failure, bool>(
        ValidationFailure('Tipo e ID são obrigatórios'),
      );
    }

    // Verifica se existe nos favoritos
    final isFavoriteResult = await _repository.isFavorito(tipo, id);

    final isFavorite = isFavoriteResult.fold(
      (failure) => throw Exception(failure.message),
      (result) => result,
    );

    if (!isFavorite) {
      return Left<Failure, bool>(
        NotFoundFailure('Favorito não encontrado: $tipo/$id'),
      );
    }

    // Tenta remover dos favoritos
    return _repository.removeFavorito(tipo, id);
  }
}
