import 'package:core/core.dart';
import '../../../../core/errors/failures.dart' as app_failures;
import '../../../../core/usecases/usecase.dart' as app_usecase;
import '../../../../core/utils/typedef.dart';
import '../entities/favorito_entity.dart';
import '../repositories/favorito_repository.dart';

/// Caso de uso para gerenciar favoritos (adicionar/remover)
/// 
/// Este use case encapsula a lógica de negócio para gerenciar
/// a lista de favoritos do usuário
class ManageFavoritoUseCase implements app_usecase.UseCase<bool, ManageFavoritoParams> {
  const ManageFavoritoUseCase(this._repository);

  final FavoritoRepository _repository;

  @override
  ResultFuture<bool> call(ManageFavoritoParams params) async {
    if (!params.isValid) {
      return const Left(
        app_failures.ServerFailure('Parâmetros inválidos para gerenciar favorito'),
      );
    }

    try {
      final isFavoritoResult = await _repository.isFavorito(params.itemId, params.tipo);
      if (isFavoritoResult.isLeft()) {
        return isFavoritoResult.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(), // Nunca será executado
        );
      }
      
      final isFavorito = isFavoritoResult.fold(
        (_) => false, // Nunca será executado porque já verificamos isLeft
        (value) => value,
      );
      
      if (isFavorito) {
        final removeResult = await _repository.removeFavorito(params.itemId, params.tipo);
        return removeResult.fold(
          (failure) => Left(failure),
          (_) => const Right(false), // Retorna false indicando que foi removido
        );
      } else {
        final favorito = FavoritoEntity(
          id: _generateFavoritoId(params.itemId, params.tipo),
          itemId: params.itemId,
          tipo: params.tipo,
          nome: params.nome,
          fabricante: params.fabricante,
          cultura: params.cultura,
          metadata: params.metadata,
          createdAt: DateTime.now(),
        );
        
        final addResult = await _repository.addFavorito(favorito);
        return addResult.fold(
          (failure) => Left(failure),
          (_) => const Right(true), // Retorna true indicando que foi adicionado
        );
      }
    } catch (e) {
      return Left(app_failures.ServerFailure('Erro ao gerenciar favorito: ${e.toString()}'));
    }
  }

  /// Gera um ID único para o favorito
  String _generateFavoritoId(String itemId, String tipo) {
    return '${tipo}_${itemId}_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Parâmetros para gerenciar favoritos
class ManageFavoritoParams {
  final String itemId;
  final String tipo;
  final String nome;
  final String? fabricante;
  final String? cultura;
  final Map<String, dynamic> metadata;

  const ManageFavoritoParams({
    required this.itemId,
    required this.tipo,
    required this.nome,
    this.fabricante,
    this.cultura,
    this.metadata = const {},
  });

  /// Valida se os parâmetros são válidos
  bool get isValid => 
      itemId.isNotEmpty && 
      tipo.isNotEmpty && 
      nome.isNotEmpty &&
      ['defensivo', 'diagnostico', 'praga'].contains(tipo);
}
