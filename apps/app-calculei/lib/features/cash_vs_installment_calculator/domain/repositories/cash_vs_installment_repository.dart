import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/cash_vs_installment_calculation.dart';

abstract class CashVsInstallmentRepository {
  Future<Either<Failure, CashVsInstallmentCalculation>> saveCalculation(CashVsInstallmentCalculation calculation);
  Future<Either<Failure, List<CashVsInstallmentCalculation>>> getCalculationHistory({int limit = 10});
  Future<Either<Failure, CashVsInstallmentCalculation>> getCalculationById(String id);
  Future<Either<Failure, void>> deleteCalculation(String id);
  Future<Either<Failure, void>> clearHistory();
}
