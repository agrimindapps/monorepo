import 'package:core/core.dart';

import '../entities/rain_gauge_entity.dart';
import '../repositories/pluviometer_repository.dart';

/// Use case para criar um novo pluviômetro com validação
class CreateRainGaugeUseCase
    implements UseCase<RainGaugeEntity, CreateRainGaugeParams> {
  final PluviometerRepository repository;

  const CreateRainGaugeUseCase(this.repository);

  @override
  Future<Either<Failure, RainGaugeEntity>> call(
      CreateRainGaugeParams params) async {
    final validation = _validateRainGaugeData(params.rainGauge);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    final now = DateTime.now();
    final rainGaugeToCreate = params.rainGauge.copyWith(
      id: params.rainGauge.id.isEmpty ? _generateUniqueId() : params.rainGauge.id,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );

    return await repository.createRainGauge(rainGaugeToCreate);
  }

  String? _validateRainGaugeData(RainGaugeEntity rainGauge) {
    if (rainGauge.description.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }

    if (rainGauge.description.trim().length < 2) {
      return 'Descrição deve ter pelo menos 2 caracteres';
    }

    if (rainGauge.capacity.trim().isEmpty) {
      return 'Capacidade é obrigatória';
    }

    // Valida coordenadas GPS se fornecidas
    if (rainGauge.latitude != null && rainGauge.longitude == null) {
      return 'Longitude é obrigatória quando latitude é informada';
    }
    if (rainGauge.longitude != null && rainGauge.latitude == null) {
      return 'Latitude é obrigatória quando longitude é informada';
    }

    if (rainGauge.latitude != null) {
      final lat = double.tryParse(rainGauge.latitude!);
      if (lat == null || lat < -90 || lat > 90) {
        return 'Latitude inválida (deve estar entre -90 e 90)';
      }
    }

    if (rainGauge.longitude != null) {
      final lon = double.tryParse(rainGauge.longitude!);
      if (lon == null || lon < -180 || lon > 180) {
        return 'Longitude inválida (deve estar entre -180 e 180)';
      }
    }

    return null;
  }

  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'rg_${timestamp}_$random';
  }
}

/// Parâmetros para criação de pluviômetro
class CreateRainGaugeParams extends Equatable {
  const CreateRainGaugeParams({
    required this.rainGauge,
  });

  final RainGaugeEntity rainGauge;

  @override
  List<Object> get props => [rainGauge];
}
