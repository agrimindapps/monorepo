import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/planta_info.dart';
import '../repositories/planta_info_repository.dart';

/// Use case to get PlantaInfo by praga ID
class GetPlantaInfoUseCase {
  final PlantaInfoRepository repository;

  GetPlantaInfoUseCase(this.repository);

  Future<Either<Failure, PlantaInfo?>> call(String pragaId) async {
    if (pragaId.isEmpty) {
      return const Left(ValidationFailure('ID da praga é obrigatório'));
    }
    return repository.getPlantaInfoByPragaId(pragaId);
  }
}
