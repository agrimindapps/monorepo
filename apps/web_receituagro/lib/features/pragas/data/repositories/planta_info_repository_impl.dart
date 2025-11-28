import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/planta_info.dart';
import '../../domain/repositories/planta_info_repository.dart';
import '../datasources/planta_info_supabase_datasource.dart';
import '../models/planta_info_model.dart';

/// Implementation of planta info repository
class PlantaInfoRepositoryImpl implements PlantaInfoRepository {
  final PlantaInfoRemoteDataSource remoteDataSource;

  PlantaInfoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PlantaInfo?>> getPlantaInfoByPragaId(String pragaId) async {
    try {
      final info = await remoteDataSource.getPlantaInfoByPragaId(pragaId);
      return Right(info);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao buscar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlantaInfo>> getPlantaInfoById(String id) async {
    try {
      final info = await remoteDataSource.getPlantaInfoById(id);
      return Right(info);
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return Left(NotFoundFailure('Informação não encontrada'));
      }
      return Left(ServerFailure('Erro ao buscar informação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlantaInfo>> createPlantaInfo(PlantaInfo info) async {
    try {
      final model = PlantaInfoModel.fromEntity(info);
      final result = await remoteDataSource.createPlantaInfo(model);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao criar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlantaInfo>> updatePlantaInfo(PlantaInfo info) async {
    try {
      final model = PlantaInfoModel.fromEntity(info);
      final result = await remoteDataSource.updatePlantaInfo(model);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao atualizar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlantaInfo>> savePlantaInfo(PlantaInfo info) async {
    try {
      // Check if info already exists
      final existingInfo = await remoteDataSource.getPlantaInfoByPragaId(info.pragaId);
      
      PlantaInfoModel result;
      if (existingInfo != null) {
        // Update existing
        final model = PlantaInfoModel.fromEntity(info.copyWith(id: existingInfo.id));
        result = await remoteDataSource.updatePlantaInfo(model);
      } else {
        // Create new
        final model = PlantaInfoModel.fromEntity(info);
        result = await remoteDataSource.createPlantaInfo(model);
      }
      
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao salvar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlantaInfo(String id) async {
    try {
      await remoteDataSource.deletePlantaInfo(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlantaInfoByPragaId(String pragaId) async {
    try {
      await remoteDataSource.deletePlantaInfoByPragaId(pragaId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar informações: ${e.toString()}'));
    }
  }
}
