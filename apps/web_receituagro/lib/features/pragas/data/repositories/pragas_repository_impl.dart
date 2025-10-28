import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/praga.dart';
import '../../domain/repositories/pragas_repository.dart';
import '../datasources/pragas_supabase_datasource.dart';

/// Implementation of pragas repository
@LazySingleton(as: PragasRepository)
class PragasRepositoryImpl implements PragasRepository {
  final PragasRemoteDataSource remoteDataSource;

  PragasRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Praga>>> getAllPragas() async {
    try {
      final pragas = await remoteDataSource.getAllPragas();
      return Right(pragas);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao buscar pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Praga>> getPragaById(String id) async {
    try {
      final praga = await remoteDataSource.getPragaById(id);
      return Right(praga);
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return Left(NotFoundFailure('Praga não encontrada'));
      }
      return Left(ServerFailure('Erro ao buscar praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Praga>>> searchPragas(String query) async {
    try {
      final pragas = await remoteDataSource.searchPragas(query);
      return Right(pragas);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao buscar pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Praga>> createPraga(Praga praga) async {
    try {
      final pragaModel = await remoteDataSource.createPraga(praga as dynamic);
      return Right(pragaModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao criar praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Praga>> updatePraga(Praga praga) async {
    try {
      final pragaModel = await remoteDataSource.updatePraga(praga as dynamic);
      return Right(pragaModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao atualizar praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePraga(String id) async {
    try {
      await remoteDataSource.deletePraga(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar praga: ${e.toString()}'));
    }
  }
}
