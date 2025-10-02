import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para atualizar uma leitura de odômetro existente
///
/// Responsável por:
/// - Validar alterações
/// - Atualizar localmente
/// - Sincronizar com Firebase em background
@injectable
class UpdateOdometerReadingUseCase implements UseCase<OdometerEntity?, OdometerEntity> {
  const UpdateOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, OdometerEntity?>> call(OdometerEntity params) async {
    try {
      // Validações
      final validation = _validateOdometerReading(params);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      // Verificar se leitura existe
      final existing = await _repository.getOdometerReadingById(params.id);
      if (existing == null) {
        return const Left(
          ValidationFailure('Leitura de odômetro não encontrada'),
        );
      }

      // Atualizar leitura
      final updatedReading = params.copyWith(
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateOdometerReading(updatedReading);

      if (result == null) {
        return const Left(
          CacheFailure('Falha ao atualizar leitura de odômetro'),
        );
      }

      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
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
