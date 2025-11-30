import 'package:core/core.dart';
import '../entities/unemployment_insurance_calculation.dart';

abstract class UnemploymentInsuranceRepository {
  Future<Either<Failure, UnemploymentInsuranceCalculation>> saveCalculation(UnemploymentInsuranceCalculation calculation);
  Future<Either<Failure, List<UnemploymentInsuranceCalculation>>> getCalculationHistory({int limit = 10});
  Future<Either<Failure, UnemploymentInsuranceCalculation>> getCalculationById(String id);
  Future<Either<Failure, void>> deleteCalculation(String id);
  Future<Either<Failure, void>> clearHistory();
}
