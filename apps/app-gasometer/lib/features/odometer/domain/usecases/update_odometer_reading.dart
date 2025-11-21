import 'package:core/core.dart';

import '../entities/odometer_entity.dart';
import '../repositories/odometer_repository.dart';

/// UseCase para atualizar uma leitura de odômetro existente
///
/// Responsável por:
/// - Validar alterações
/// - Atualizar localmente
/// - Sincronizar com Firebase em background

class UpdateOdometerReadingUseCase
    implements UseCase<OdometerEntity?, OdometerEntity> {
  const UpdateOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, OdometerEntity?>> call(OdometerEntity params) async {
    try {
      final validation = _validateOdometerReading(params);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      final existingResult = await _repository.getOdometerReadingById(
        params.id,
      );
      return existingResult.fold((failure) => Left(failure), (existing) async {
        if (existing == null) {
          return const Left(
            ValidationFailure('Leitura de odômetro não encontrada'),
          );
        }

        final updatedReading = params.copyWith(updatedAt: DateTime.now());

        final updateResult = await _repository.updateOdometerReading(
          updatedReading,
        );
        return updateResult.fold(
          (failure) => Left(failure),
          (result) => Right(result),
        );
      });
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao atualizar leitura: ${e.toString()}'),
      );
    }
  }

  String? _validateOdometerReading(OdometerEntity reading) {
    if (reading.id.trim().isEmpty) {
      return 'ID da leitura é obrigatório';
    }

    if (reading.vehicleId.trim().isEmpty) {
      return 'Veículo é obrigatório';
    }

    if (reading.value < 0) {
      return 'Valor do odômetro não pode ser negativo';
    }

    if (reading.value > 9999999) {
      return 'Valor do odômetro muito alto (máximo: 9.999.999 km)';
    }

    return null;
  }
}
