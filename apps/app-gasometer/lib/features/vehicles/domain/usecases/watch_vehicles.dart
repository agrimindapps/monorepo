import 'package:core/core.dart';

import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

/// UseCase para observar mudanças em tempo real nos veículos
///
/// Responsável por:
/// - Retornar um stream com atualizações automáticas dos veículos
/// - Integrar com Firebase para sincronização em tempo real
/// - Manter a lista de veículos sempre atualizada

class WatchVehicles {
  const WatchVehicles(this._repository);

  final VehicleRepository _repository;

  /// Returns a stream that emits updates whenever vehicles change
  Stream<Either<Failure, List<VehicleEntity>>> call() {
    return _repository.watchVehicles();
  }
}
