import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/defensivo_info.dart';
import '../../domain/repositories/defensivos_info_repository.dart';
import '../datasources/defensivos_info_remote_datasource.dart';
import '../models/defensivo_info_model.dart';

/// Implementation of DefensivosInfoRepository
@LazySingleton(as: DefensivosInfoRepository)
class DefensivosInfoRepositoryImpl implements DefensivosInfoRepository {
  final DefensivosInfoRemoteDataSource remoteDataSource;

  const DefensivosInfoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DefensivoInfo?>> getDefensivoInfoByDefensivoId(
    String defensivoId,
  ) async {
    try {
      // Validate ID
      if (defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      final model = await remoteDataSource.getDefensivoInfoByDefensivoId(
        defensivoId,
      );

      // Return null if not found (optional relationship)
      if (model == null) {
        return const Right(null);
      }

      return Right(model as DefensivoInfo);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, DefensivoInfo>> getDefensivoInfoById(String id) async {
    try {
      // Validate ID
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID da informação é obrigatório'));
      }

      final model = await remoteDataSource.getDefensivoInfoById(id);

      return Right(model as DefensivoInfo);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Informação não encontrada'));
      }
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      if (e.toString().contains('não encontrada')) {
        return const Left(NotFoundFailure('Informação não encontrada'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, DefensivoInfo>> createDefensivoInfo(
    DefensivoInfo info,
  ) async {
    try {
      // Validate required field
      if (info.defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      final model = await remoteDataSource.createDefensivoInfo(
        info as DefensivoInfoModel,
      );

      return Right(model as DefensivoInfo);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, DefensivoInfo>> updateDefensivoInfo(
    DefensivoInfo info,
  ) async {
    try {
      // Validate ID
      if (info.id.trim().isEmpty) {
        return const Left(ValidationFailure('ID da informação é obrigatório'));
      }

      // Validate required field
      if (info.defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      final model = await remoteDataSource.updateDefensivoInfo(
        info as DefensivoInfoModel,
      );

      return Right(model as DefensivoInfo);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Informação não encontrada'));
      }
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      if (e.toString().contains('não encontrada')) {
        return const Left(NotFoundFailure('Informação não encontrada'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDefensivoInfo(String id) async {
    try {
      // Validate ID
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID da informação é obrigatório'));
      }

      await remoteDataSource.deleteDefensivoInfo(id);

      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDefensivoInfoByDefensivoId(
    String defensivoId,
  ) async {
    try {
      // Validate ID
      if (defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      await remoteDataSource.deleteDefensivoInfoByDefensivoId(defensivoId);

      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }
}
