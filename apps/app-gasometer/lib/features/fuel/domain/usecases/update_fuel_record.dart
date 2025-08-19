import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@lazySingleton
class UpdateFuelRecord implements UseCase<FuelRecordEntity, UpdateFuelRecordParams> {
  final FuelRepository repository;

  UpdateFuelRecord(this.repository);

  @override
  Future<Either<Failure, FuelRecordEntity>> call(UpdateFuelRecordParams params) async {
    // Validate fuel record data
    final validationResult = _validateFuelRecord(params.fuelRecord);
    if (validationResult.isLeft()) {
      return validationResult.fold((failure) => Left(failure), (_) => throw Exception());
    }

    return await repository.updateFuelRecord(params.fuelRecord);
  }

  Either<Failure, Unit> _validateFuelRecord(FuelRecordEntity fuelRecord) {
    if (fuelRecord.id.isEmpty) {
      return const Left(InvalidFuelDataFailure('ID do registro é obrigatório'));
    }

    if (fuelRecord.vehicleId.isEmpty) {
      return const Left(InvalidFuelDataFailure('ID do veículo é obrigatório'));
    }

    if (fuelRecord.liters <= 0) {
      return const Left(InvalidFuelDataFailure('Quantidade de litros deve ser maior que zero'));
    }

    if (fuelRecord.pricePerLiter <= 0) {
      return const Left(InvalidFuelDataFailure('Preço por litro deve ser maior que zero'));
    }

    if (fuelRecord.totalPrice <= 0) {
      return const Left(InvalidFuelDataFailure('Valor total deve ser maior que zero'));
    }

    if (fuelRecord.odometer <= 0) {
      return const Left(InvalidFuelDataFailure('Odômetro deve ser maior que zero'));
    }

    // Validate price consistency
    final calculatedTotal = fuelRecord.liters * fuelRecord.pricePerLiter;
    final difference = (fuelRecord.totalPrice - calculatedTotal).abs();
    final tolerance = calculatedTotal * 0.05; // 5% tolerance

    if (difference > tolerance) {
      return const Left(InvalidFuelDataFailure('Valor total não confere com litros × preço por litro'));
    }

    return const Right(unit);
  }
}

class UpdateFuelRecordParams extends UseCaseParams {
  final FuelRecordEntity fuelRecord;

  const UpdateFuelRecordParams({required this.fuelRecord});

  @override
  List<Object> get props => [fuelRecord];
}