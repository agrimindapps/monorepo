import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/planta_info.dart';
import '../repositories/planta_info_repository.dart';

/// Use case to save PlantaInfo (create or update)
class SavePlantaInfoUseCase {
  final PlantaInfoRepository repository;

  SavePlantaInfoUseCase(this.repository);

  Future<Either<Failure, PlantaInfo>> call(PlantaInfo info) async {
    // Validation
    if (info.pragaId.isEmpty) {
      return const Left(ValidationFailure('ID da praga é obrigatório'));
    }

    // Update timestamp
    final updatedInfo = info.copyWith(
      updatedAt: DateTime.now(),
    );

    return repository.savePlantaInfo(updatedInfo);
  }
}
