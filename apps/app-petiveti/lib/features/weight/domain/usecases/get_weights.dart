import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/weight.dart';
import '../repositories/weight_repository.dart';

class GetWeights implements UseCase<List<Weight>, NoParams> {
  final WeightRepository repository;

  GetWeights(this.repository);

  @override
  Future<Either<Failure, List<Weight>>> call(NoParams params) async {
    return await repository.getWeights();
  }
}
