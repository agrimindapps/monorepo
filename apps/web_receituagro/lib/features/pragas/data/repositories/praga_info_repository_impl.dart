import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/praga_info.dart';
import '../../domain/repositories/praga_info_repository.dart';
import '../datasources/praga_info_supabase_datasource.dart';
import '../models/praga_info_model.dart';

/// Implementation of praga info repository
class PragaInfoRepositoryImpl implements PragaInfoRepository {
  final PragaInfoRemoteDataSource remoteDataSource;

  PragaInfoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PragaInfo?>> getPragaInfoByPragaId(String pragaId) async {
    try {
      final info = await remoteDataSource.getPragaInfoByPragaId(pragaId);
      return Right(info);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao buscar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PragaInfo>> getPragaInfoById(String id) async {
    try {
      final info = await remoteDataSource.getPragaInfoById(id);
      return Right(info);
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return Left(NotFoundFailure('Informação não encontrada'));
      }
      return Left(ServerFailure('Erro ao buscar informação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PragaInfo>> createPragaInfo(PragaInfo info) async {
    try {
      final model = PragaInfoModel.fromEntity(info);
      final result = await remoteDataSource.createPragaInfo(model);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao criar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PragaInfo>> updatePragaInfo(PragaInfo info) async {
    try {
      final model = PragaInfoModel.fromEntity(info);
      final result = await remoteDataSource.updatePragaInfo(model);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao atualizar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PragaInfo>> savePragaInfo(PragaInfo info) async {
    try {
      // Check if info already exists
      final existingInfo = await remoteDataSource.getPragaInfoByPragaId(info.pragaId);
      
      PragaInfoModel result;
      if (existingInfo != null) {
        // Update existing
        final model = PragaInfoModel.fromEntity(info.copyWith(id: existingInfo.id));
        result = await remoteDataSource.updatePragaInfo(model);
      } else {
        // Create new
        final model = PragaInfoModel.fromEntity(info);
        result = await remoteDataSource.createPragaInfo(model);
      }
      
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao salvar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePragaInfo(String id) async {
    try {
      await remoteDataSource.deletePragaInfo(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar informações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePragaInfoByPragaId(String pragaId) async {
    try {
      await remoteDataSource.deletePragaInfoByPragaId(pragaId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar informações: ${e.toString()}'));
    }
  }
}
