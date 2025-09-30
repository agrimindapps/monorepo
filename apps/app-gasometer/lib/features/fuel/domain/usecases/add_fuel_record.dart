import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@injectable
class AddFuelRecord implements UseCase<FuelRecordEntity, AddFuelRecordParams> {

  AddFuelRecord(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, FuelRecordEntity>> call(AddFuelRecordParams params) async {
    // Validate fuel record data
    final validationResult = _validateFuelRecord(params.fuelRecord);
    if (validationResult.isLeft()) {
      return validationResult.fold((failure) => Left(failure), (_) => throw Exception());
    }

    return repository.addFuelRecord(params.fuelRecord);
  }

  Either<Failure, Unit> _validateFuelRecord(FuelRecordEntity fuelRecord) {
    if (fuelRecord.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (fuelRecord.liters <= 0) {
      return const Left(ValidationFailure('Quantidade de litros deve ser maior que zero'));
    }

    if (fuelRecord.pricePerLiter <= 0) {
      return const Left(ValidationFailure('Preço por litro deve ser maior que zero'));
    }

    if (fuelRecord.totalPrice <= 0) {
      return const Left(ValidationFailure('Valor total deve ser maior que zero'));
    }

    if (fuelRecord.odometer <= 0) {
      return const Left(ValidationFailure('Odômetro deve ser maior que zero'));
    }

    // Validate price consistency (total should match liters * pricePerLiter within tolerance)
    final calculatedTotal = fuelRecord.liters * fuelRecord.pricePerLiter;
    final difference = (fuelRecord.totalPrice - calculatedTotal).abs();
    final tolerance = calculatedTotal * 0.05; // 5% tolerance

    if (difference > tolerance) {
      return const Left(ValidationFailure('Valor total não confere com litros × preço por litro'));
    }

    return const Right(unit);
  }
}

class AddFuelRecordParams with EquatableMixin {

  const AddFuelRecordParams({required this.fuelRecord});
  final FuelRecordEntity fuelRecord;

  @override
  List<Object> get props => [fuelRecord];
}