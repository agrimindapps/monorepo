import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/cash_vs_installment_calculation.dart';
import '../repositories/cash_vs_installment_repository.dart';

@injectable
class GetCashVsInstallmentCalculationHistoryUseCase {
  final CashVsInstallmentRepository _repository;

  GetCashVsInstallmentCalculationHistoryUseCase(this._repository);

  Future<Either<Failure, List<CashVsInstallmentCalculation>>> call({int limit = 10}) async {
    return _repository.getCalculationHistory(limit: limit);
  }
}
