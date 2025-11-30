import 'package:core/core.dart';

import '../entities/rainfall_measurement_entity.dart';
import '../repositories/pluviometer_repository.dart';

/// Use case para obter todas as medições
class GetMeasurementsUseCase
    implements UseCase<List<RainfallMeasurementEntity>, GetMeasurementsParams> {
  final PluviometerRepository repository;

  const GetMeasurementsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RainfallMeasurementEntity>>> call(
      GetMeasurementsParams params) async {
    if (params.rainGaugeId != null && params.rainGaugeId!.isNotEmpty) {
      if (params.start != null && params.end != null) {
        return await repository.getMeasurementsByRainGaugeAndPeriod(
          params.rainGaugeId!,
          params.start!,
          params.end!,
        );
      }
      return await repository.getMeasurementsByRainGauge(params.rainGaugeId!);
    }

    if (params.start != null && params.end != null) {
      return await repository.getMeasurementsByPeriod(params.start!, params.end!);
    }

    return await repository.getMeasurements();
  }
}

/// Parâmetros para busca de medições
class GetMeasurementsParams extends Equatable {
  const GetMeasurementsParams({
    this.rainGaugeId,
    this.start,
    this.end,
  });

  final String? rainGaugeId;
  final DateTime? start;
  final DateTime? end;

  @override
  List<Object?> get props => [rainGaugeId, start, end];
}

/// Use case para obter medição por ID
class GetMeasurementByIdUseCase
    implements UseCase<RainfallMeasurementEntity, GetMeasurementByIdParams> {
  final PluviometerRepository repository;

  const GetMeasurementByIdUseCase(this.repository);

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> call(
      GetMeasurementByIdParams params) async {
    if (params.id.trim().isEmpty) {
      return const Left(ValidationFailure('ID da medição é obrigatório'));
    }
    return await repository.getMeasurementById(params.id);
  }
}

/// Parâmetros para busca por ID
class GetMeasurementByIdParams extends Equatable {
  const GetMeasurementByIdParams({required this.id});

  final String id;

  @override
  List<Object> get props => [id];
}

/// Use case para atualizar uma medição
class UpdateMeasurementUseCase
    implements UseCase<RainfallMeasurementEntity, UpdateMeasurementParams> {
  final PluviometerRepository repository;

  const UpdateMeasurementUseCase(this.repository);

  @override
  Future<Either<Failure, RainfallMeasurementEntity>> call(
      UpdateMeasurementParams params) async {
    final validation = _validateMeasurementData(params.measurement);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    final measurementToUpdate = params.measurement.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateMeasurement(measurementToUpdate);
  }

  String? _validateMeasurementData(RainfallMeasurementEntity measurement) {
    if (measurement.id.trim().isEmpty) {
      return 'ID da medição é obrigatório';
    }

    if (measurement.rainGaugeId.trim().isEmpty) {
      return 'Pluviômetro é obrigatório';
    }

    if (measurement.amount < 0) {
      return 'Quantidade não pode ser negativa';
    }

    if (measurement.amount > 1000) {
      return 'Quantidade parece inválida (máximo 1000mm)';
    }

    return null;
  }
}

/// Parâmetros para atualização de medição
class UpdateMeasurementParams extends Equatable {
  const UpdateMeasurementParams({required this.measurement});

  final RainfallMeasurementEntity measurement;

  @override
  List<Object> get props => [measurement];
}

/// Use case para deletar uma medição
class DeleteMeasurementUseCase
    implements UseCase<Unit, DeleteMeasurementParams> {
  final PluviometerRepository repository;

  const DeleteMeasurementUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteMeasurementParams params) async {
    if (params.id.trim().isEmpty) {
      return const Left(ValidationFailure('ID da medição é obrigatório'));
    }
    return await repository.deleteMeasurement(params.id);
  }
}

/// Parâmetros para deleção de medição
class DeleteMeasurementParams extends Equatable {
  const DeleteMeasurementParams({required this.id});

  final String id;

  @override
  List<Object> get props => [id];
}
