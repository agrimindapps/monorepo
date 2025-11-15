import 'package:core/core.dart';

import '../entities/favorito_entity.dart';
import '../repositories/i_favoritos_repository.dart';

/// UseCase genérico para adicionar qualquer tipo de favorito
/// Substitui os específicos (AddFavoritoDefensivoUseCase, AddFavoritoPragaUseCase, etc)
///
/// **Benefício:** Consolidação de 4+ usecases em 1 genérico reutilizável
///
/// Vantagem: Reutilizável para Defensivos, Pragas, Diagnósticos, Culturas
@injectable
class AddFavoritoUseCase {
  final IFavoritosRepository _repository;

  const AddFavoritoUseCase(this._repository);

  /// Adiciona um favorito genérico
  ///
  /// **Exemplo de uso:**
  /// ```dart
  /// final defensivo = FavoritoDefensivoEntity(
  ///   id: '123',
  ///   nomeComum: 'Defensivo XYZ',
  ///   ingredienteAtivo: 'Ativo ABC',
  /// );
  ///
  /// final result = await addFavoritoUseCase(defensivo);
  /// result.fold(
  ///   (failure) => print('Erro: ${failure.message}'),
  ///   (success) => print('✓ Adicionado aos favoritos'),
  /// );
  /// ```
  ///
  /// **Tipos suportados:**
  /// - `FavoritoDefensivoEntity` (tipo: TipoFavorito.defensivo)
  /// - `FavoritoPragaEntity` (tipo: TipoFavorito.praga)
  /// - `FavoritoDiagnosticoEntity` (tipo: TipoFavorito.diagnostico)
  /// - `FavoritoCulturaEntity` (tipo: TipoFavorito.cultura)
  Future<Either<Failure, bool>> call(FavoritoEntity favorito) async {
    // Validação de ID
    if (favorito.id.isEmpty) {
      return Left<Failure, bool>(
        ValidationFailure('ID do favorito é obrigatório'),
      );
    }

    // Verifica se já existe nos favoritos
    final isAlreadyFavoriteResult = await _repository.isFavorito(
      favorito.tipo,
      favorito.id,
    );

    // Processa o resultado do isFavorito
    final isAlreadyFavorite = isAlreadyFavoriteResult.fold(
      (failure) => throw Exception(failure.message),
      (result) => result,
    );

    if (isAlreadyFavorite) {
      return Left<Failure, bool>(
        ValidationFailure('Já está nos favoritos: ${favorito.id}'),
      );
    }

    // Tenta adicionar aos favoritos
    return _repository.addFavorito(favorito);
  }
}
