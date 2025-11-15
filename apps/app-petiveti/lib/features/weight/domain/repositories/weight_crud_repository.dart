import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';

/// **ISP - Interface Segregation Principle**
/// CRUD operations (Create, Read, Update, Delete)
/// Single Responsibility: Handle weight record lifecycle operations
abstract class WeightCrudRepository {
  /// Adiciona um novo registro de peso
  Future<Either<Failure, void>> addWeight(Weight weight);

  /// Retorna um registro de peso específico pelo ID
  Future<Either<Failure, Weight>> getWeightById(String id);

  /// Atualiza um registro de peso existente
  Future<Either<Failure, void>> updateWeight(Weight weight);

  /// Remove um registro de peso (soft delete)
  Future<Either<Failure, void>> deleteWeight(String id);

  /// Remove permanentemente um registro de peso
  Future<Either<Failure, void>> hardDeleteWeight(String id);
}
