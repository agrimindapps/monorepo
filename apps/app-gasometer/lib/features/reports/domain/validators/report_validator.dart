import 'package:core/core.dart';

abstract class ReportValidator {
  Either<Failure, Unit> validateVehicleId(String vehicleId);
  Either<Failure, Unit> validateDateRange(DateTime startDate, DateTime endDate);
  Either<Failure, Unit> validateYear(int year);
  Either<Failure, Unit> validateMonthsRange(int months);
}

@LazySingleton(as: ReportValidator)
class ReportValidatorImpl implements ReportValidator {
  @override
  Either<Failure, Unit> validateVehicleId(String vehicleId) {
    if (vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }
    return const Right(unit);
  }

  @override
  Either<Failure, Unit> validateDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      return const Left(ValidationFailure('Data inicial não pode ser posterior à data final'));
    }
    if (endDate.isAfter(DateTime.now())) {
      return const Left(ValidationFailure('Data final não pode ser no futuro'));
    }
    return const Right(unit);
  }

  @override
  Either<Failure, Unit> validateYear(int year) {
    if (year < 2000 || year > DateTime.now().year + 1) {
      return const Left(ValidationFailure('Ano inválido'));
    }
    return const Right(unit);
  }

  @override
  Either<Failure, Unit> validateMonthsRange(int months) {
    if (months <= 0 || months > 24) {
      return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
    }
    return const Right(unit);
  }
}
