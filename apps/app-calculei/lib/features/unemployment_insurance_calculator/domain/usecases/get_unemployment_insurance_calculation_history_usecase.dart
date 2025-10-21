import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/unemployment_insurance_calculation.dart';
import '../repositories/unemployment_insurance_repository.dart';

@injectable
class GetUnemploymentInsuranceCalculationHistoryUseCase {
  final UnemploymentInsuranceRepository _repository;

  GetUnemploymentInsuranceCalculationHistoryUseCase(this._repository);

  Future<Either<Failure, List<UnemploymentInsuranceCalculation>>> call({int limit = 10}) async {
    return _repository.getCalculationHistory(limit: limit);
  }
}
