import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';

/// **ISP - Interface Segregation Principle**
/// Query operations (List, Search, History)
/// Single Responsibility: Handle weight data retrieval and filtering
abstract class WeightQueryRepository {
  /// Retorna todos os registros de peso não deletados
  Future<Either<Failure, List<Weight>>> getWeights();

  /// Retorna registros de peso de um animal específico
  Future<Either<Failure, List<Weight>>> getWeightsByAnimalId(String animalId);

  /// Retorna o último registro de peso de um animal
  Future<Either<Failure, Weight?>> getLatestWeightByAnimalId(String animalId);

  /// Retorna histórico de peso por período
  Future<Either<Failure, List<Weight>>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Busca registros de peso por critérios
  Future<Either<Failure, List<Weight>>> searchWeights(
    String animalId, {
    double? minWeight,
    double? maxWeight,
    DateTime? startDate,
    DateTime? endDate,
    int? bodyConditionScore,
  });

  /// Conta total de registros de peso por animal
  Future<Either<Failure, int>> getWeightRecordsCount(String animalId);
}
