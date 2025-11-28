import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/planta_info.dart';

/// PlantaInfo repository interface - Domain layer
abstract class PlantaInfoRepository {
  Future<Either<Failure, PlantaInfo?>> getPlantaInfoByPragaId(String pragaId);
  Future<Either<Failure, PlantaInfo>> getPlantaInfoById(String id);
  Future<Either<Failure, PlantaInfo>> createPlantaInfo(PlantaInfo info);
  Future<Either<Failure, PlantaInfo>> updatePlantaInfo(PlantaInfo info);
  Future<Either<Failure, PlantaInfo>> savePlantaInfo(PlantaInfo info);
  Future<Either<Failure, void>> deletePlantaInfo(String id);
  Future<Either<Failure, void>> deletePlantaInfoByPragaId(String pragaId);
}
