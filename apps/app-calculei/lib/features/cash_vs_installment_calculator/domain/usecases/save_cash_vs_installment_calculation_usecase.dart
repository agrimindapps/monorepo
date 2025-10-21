import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/cash_vs_installment_calculation.dart';
import '../repositories/cash_vs_installment_repository.dart';

@injectable
class SaveCashVsInstallmentCalculationUseCase {
  final CashVsInstallmentRepository _repository;

  SaveCashVsInstallmentCalculationUseCase(this._repository);

  Future<Either<Failure, CashVsInstallmentCalculation>> call(CashVsInstallmentCalculation calculation) async {
    return _repository.saveCalculation(calculation);
  }
}
