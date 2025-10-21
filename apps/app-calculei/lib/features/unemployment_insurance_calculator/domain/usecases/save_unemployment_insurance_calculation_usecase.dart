import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/unemployment_insurance_calculation.dart';
import '../repositories/unemployment_insurance_repository.dart';

@injectable
class SaveUnemploymentInsuranceCalculationUseCase {
  final UnemploymentInsuranceRepository _repository;

  SaveUnemploymentInsuranceCalculationUseCase(this._repository);

  Future<Either<Failure, UnemploymentInsuranceCalculation>> call(UnemploymentInsuranceCalculation calculation) async {
    return _repository.saveCalculation(calculation);
  }
}
