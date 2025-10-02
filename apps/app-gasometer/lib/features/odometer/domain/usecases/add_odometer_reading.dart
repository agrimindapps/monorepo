import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para adicionar uma nova leitura de odômetro
///
/// Responsável por:
/// - Validar dados da leitura
/// - Persistir localmente (Hive)
/// - Sincronizar com Firebase em background
@injectable
class AddOdometerReadingUseCase implements UseCase<OdometerEntity?, OdometerEntity> {
  const AddOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, OdometerEntity?>> call(OdometerEntity params) async {
    try {
      // Validações básicas
      final validation = _validateOdometerReading(params);
      if (validation != null) {
        return Left(ValidationFailure(validation));
      }

      // Salvar leitura
      final result = await _repository.saveOdometerReading(params);

      if (result == null) {
        return const Left(
          CacheFailure('Falha ao salvar leitura de odômetro'),
        );
      }

      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao adicionar leitura: ${e.toString()}'),
      );
    }
  }

  /// Valida dados da leitura de odômetro
  String? _validateOdometerReading(OdometerEntity reading) {
    if (reading.vehicleId.trim().isEmpty) {
      return 'Veículo é obrigatório';
    }

    if (reading.value < 0) {
      return 'Valor do odômetro não pode ser negativo';
    }

    if (reading.value > 9999999) {
      return 'Valor do odômetro muito alto (máximo: 9.999.999 km)';
    }

    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 1));
    if (reading.registrationDate.isAfter(maxFutureDate)) {
      return 'Data não pode ser mais de 1 dia no futuro';
    }

    final minPastDate = DateTime(2000);
    if (reading.registrationDate.isBefore(minPastDate)) {
      return 'Data muito antiga (mínimo: 2000)';
    }

    return null;
  }
}
