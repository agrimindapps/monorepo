import 'package:core/core.dart';

import '../entities/rainfall_measurement_entity.dart';
import '../repositories/pluviometer_repository.dart';

/// Use case para criar uma nova medição pluviométrica
class CreateMeasurementUseCase
    implements UseCase<RainfallMeasurementEntity, CreateMeasurementParams> {
  final PluviometerRepository repository;

  const CreateMeasurementUseCase(this.repository);

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> call(
      CreateMeasurementParams params) async {
    final validation = _validateMeasurementData(params.measurement);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    final now = DateTime.now();
    final measurementToCreate = params.measurement.copyWith(
      id: params.measurement.id.isEmpty
          ? _generateUniqueId()
          : params.measurement.id,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );

    return await repository.createMeasurement(measurementToCreate);
  }

  String? _validateMeasurementData(RainfallMeasurementEntity measurement) {
    if (measurement.rainGaugeId.trim().isEmpty) {
      return 'Pluviômetro é obrigatório';
    }

    if (measurement.amount < 0) {
      return 'Quantidade não pode ser negativa';
    }

    if (measurement.amount > 1000) {
      return 'Quantidade parece inválida (máximo 1000mm)';
    }

    if (measurement.measurementDate.isAfter(DateTime.now())) {
      return 'Data da medição não pode ser futura';
    }

    return null;
  }

  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'rm_${timestamp}_$random';
  }
}

/// Parâmetros para criação de medição
class CreateMeasurementParams extends Equatable {
  const CreateMeasurementParams({
    required this.measurement,
  });

  final RainfallMeasurementEntity measurement;

  @override
  List<Object> get props => [measurement];
}
