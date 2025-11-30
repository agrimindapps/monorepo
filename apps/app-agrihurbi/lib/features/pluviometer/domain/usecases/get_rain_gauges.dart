import 'package:core/core.dart';

import '../entities/rain_gauge_entity.dart';
import '../repositories/pluviometer_repository.dart';

/// Use case para obter todos os pluviômetros
class GetRainGaugesUseCase implements UseCase<List<RainGaugeEntity>, NoParams> {
  final PluviometerRepository repository;

  const GetRainGaugesUseCase(this.repository);

  @override
  Future<Either<Failure, List<RainGaugeEntity>>> call(NoParams params) async {
    return await repository.getRainGauges();
  }
}

/// Use case para obter pluviômetro por ID
class GetRainGaugeByIdUseCase
    implements UseCase<RainGaugeEntity, GetRainGaugeByIdParams> {
  final PluviometerRepository repository;

  const GetRainGaugeByIdUseCase(this.repository);

  @override
  Future<Either<Failure, RainGaugeEntity>> call(
      GetRainGaugeByIdParams params) async {
    if (params.id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do pluviômetro é obrigatório'));
    }
    return await repository.getRainGaugeById(params.id);
  }
}

/// Parâmetros para busca por ID
class GetRainGaugeByIdParams extends Equatable {
  const GetRainGaugeByIdParams({required this.id});

  final String id;

  @override
  List<Object> get props => [id];
}

/// Use case para atualizar um pluviômetro
class UpdateRainGaugeUseCase
    implements UseCase<RainGaugeEntity, UpdateRainGaugeParams> {
  final PluviometerRepository repository;

  const UpdateRainGaugeUseCase(this.repository);

  @override
  Future<Either<Failure, RainGaugeEntity>> call(
      UpdateRainGaugeParams params) async {
    final validation = _validateRainGaugeData(params.rainGauge);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    final rainGaugeToUpdate = params.rainGauge.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateRainGauge(rainGaugeToUpdate);
  }

  String? _validateRainGaugeData(RainGaugeEntity rainGauge) {
    if (rainGauge.id.trim().isEmpty) {
      return 'ID do pluviômetro é obrigatório';
    }

    if (rainGauge.description.trim().isEmpty) {
      return 'Descrição é obrigatória';
    }

    if (rainGauge.description.trim().length < 2) {
      return 'Descrição deve ter pelo menos 2 caracteres';
    }

    if (rainGauge.capacity.trim().isEmpty) {
      return 'Capacidade é obrigatória';
    }

    return null;
  }
}

/// Parâmetros para atualização de pluviômetro
class UpdateRainGaugeParams extends Equatable {
  const UpdateRainGaugeParams({required this.rainGauge});

  final RainGaugeEntity rainGauge;

  @override
  List<Object> get props => [rainGauge];
}

/// Use case para deletar um pluviômetro
class DeleteRainGaugeUseCase implements UseCase<Unit, DeleteRainGaugeParams> {
  final PluviometerRepository repository;

  const DeleteRainGaugeUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteRainGaugeParams params) async {
    if (params.id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do pluviômetro é obrigatório'));
    }
    return await repository.deleteRainGauge(params.id);
  }
}

/// Parâmetros para deleção de pluviômetro
class DeleteRainGaugeParams extends Equatable {
  const DeleteRainGaugeParams({required this.id});

  final String id;

  @override
  List<Object> get props => [id];
}
