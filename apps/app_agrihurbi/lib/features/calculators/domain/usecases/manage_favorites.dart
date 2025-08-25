import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../repositories/calculator_repository.dart';

/// Parâmetros base para operações de favoritos
abstract class FavoriteParams {
  const FavoriteParams();
}

/// Parâmetros para obter favoritos
class GetFavoritesParams extends FavoriteParams {
  const GetFavoritesParams();
}

/// Parâmetros para adicionar favorito
class AddFavoriteParams extends FavoriteParams {
  final String calculatorId;
  
  const AddFavoriteParams(this.calculatorId);
}

/// Parâmetros para remover favorito  
class RemoveFavoriteParams extends FavoriteParams {
  final String calculatorId;
  
  const RemoveFavoriteParams(this.calculatorId);
}

/// Use case unificado para gerenciar favoritos
/// 
/// Segue padrão Clean Architecture com Either para error handling
/// Utiliza pattern matching para diferentes operações
class ManageFavorites {
  final CalculatorRepository repository;

  ManageFavorites(this.repository);

  Future<Either<Failure, dynamic>> call(FavoriteParams params) async {
    if (params is GetFavoritesParams) {
      return await repository.getFavoriteCalculators();
    } else if (params is AddFavoriteParams) {
      return await repository.addToFavorites(params.calculatorId);
    } else if (params is RemoveFavoriteParams) {
      return await repository.removeFromFavorites(params.calculatorId);
    } else {
      return const Left(ValidationFailure(message: 'Parâmetro de favorito inválido'));
    }
  }
}

/// Use cases específicos para cada operação (para manter compatibilidade)
class GetFavoriteCalculators {
  final CalculatorRepository repository;

  GetFavoriteCalculators(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getFavoriteCalculators();
  }
}

class AddToFavorites {
  final CalculatorRepository repository;

  AddToFavorites(this.repository);

  Future<Either<Failure, Unit>> call(String calculatorId) async {
    return await repository.addToFavorites(calculatorId);
  }
}

class RemoveFromFavorites {
  final CalculatorRepository repository;

  RemoveFromFavorites(this.repository);

  Future<Either<Failure, Unit>> call(String calculatorId) async {
    return await repository.removeFromFavorites(calculatorId);
  }
}