import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cultura.dart';
import '../../domain/repositories/culturas_repository.dart';
import '../datasources/culturas_supabase_datasource.dart';

/// Implementation of culturas repository
@LazySingleton(as: CulturasRepository)
class CulturasRepositoryImpl implements CulturasRepository {
  final CulturasRemoteDataSource remoteDataSource;

  CulturasRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Cultura>>> getAllCulturas() async {
    try {
      final culturas = await remoteDataSource.getAllCulturas();
      return Right(culturas);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cultura>> getCulturaById(String id) async {
    try {
      final cultura = await remoteDataSource.getCulturaById(id);
      return Right(cultura);
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return Left(NotFoundFailure('Cultura não encontrada'));
      }
      return Left(ServerFailure('Erro ao buscar cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Cultura>>> searchCulturas(String query) async {
    try {
      final culturas = await remoteDataSource.searchCulturas(query);
      return Right(culturas);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cultura>> createCultura(Cultura cultura) async {
    try {
      final culturaModel = await remoteDataSource.createCultura(
        // Convert entity to model (you may need CulturaModel.fromEntity)
        cultura as dynamic,
      );
      return Right(culturaModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao criar cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Cultura>> updateCultura(Cultura cultura) async {
    try {
      final culturaModel = await remoteDataSource.updateCultura(
        cultura as dynamic,
      );
      return Right(culturaModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao atualizar cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCultura(String id) async {
    try {
      await remoteDataSource.deleteCultura(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar cultura: ${e.toString()}'));
    }
  }
}
