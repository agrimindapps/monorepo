import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/weight_repository.dart';

class GetWeightStatistics implements UseCase<WeightStatistics, String> {
  final WeightRepository repository;

  GetWeightStatistics(this.repository);

  @override
  Future<Either<Failure, WeightStatistics>> call(String animalId) async {
    if (animalId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }
    
    return await repository.getWeightStatistics(animalId);
  }
}

class AnalyzeWeightTrend implements UseCase<WeightTrendAnalysis, AnalyzeWeightTrendParams> {
  final WeightRepository repository;

  AnalyzeWeightTrend(this.repository);

  @override
  Future<Either<Failure, WeightTrendAnalysis>> call(AnalyzeWeightTrendParams params) async {
    if (params.animalId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }
    
    if (params.periodInDays <= 0) {
      return const Left(ValidationFailure(message: 'Período deve ser maior que zero'));
    }
    
    return await repository.analyzeWeightTrend(
      params.animalId,
      periodInDays: params.periodInDays,
    );
  }
}

class AnalyzeWeightTrendParams {
  final String animalId;
  final int periodInDays;

  const AnalyzeWeightTrendParams({
    required this.animalId,
    this.periodInDays = 90,
  });
}