import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/vaccine.dart';
import '../../domain/repositories/vaccine_repository.dart';
import '../datasources/vaccine_local_datasource.dart';
import '../models/vaccine_model.dart';

class VaccineRepositoryImpl implements VaccineRepository {
  final VaccineLocalDataSource localDataSource;

  VaccineRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccines(String animalId) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByAnimalId(animalId);
      final vaccines = vaccineModels.map((model) => model.toEntity()).toList();
      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacinas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getPendingVaccines(String animalId) async {
    try {
      final vaccineModels = await localDataSource.getUpcomingVaccines();
      // Filter by animal ID
      final filteredModels = vaccineModels.where((model) => model.animalId == animalId).toList();
      final vaccines = filteredModels.map((model) => model.toEntity()).toList();
      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacinas pendentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getOverdueVaccines(String animalId) async {
    try {
      final vaccineModels = await localDataSource.getOverdueVaccines();
      // Filter by animal ID
      final filteredModels = vaccineModels.where((model) => model.animalId == animalId).toList();
      final vaccines = filteredModels.map((model) => model.toEntity()).toList();
      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacinas atrasadas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine?>> getVaccineById(String id) async {
    try {
      final vaccineModel = await localDataSource.getVaccineById(id);
      if (vaccineModel == null) {
        return const Right(null);
      }
      return Right(vaccineModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine>> addVaccine(Vaccine vaccine) async {
    try {
      final vaccineModel = VaccineModel.fromEntity(vaccine);
      await localDataSource.cacheVaccine(vaccineModel);
      return Right(vaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao adicionar vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine>> updateVaccine(Vaccine vaccine) async {
    try {
      final vaccineModel = VaccineModel.fromEntity(vaccine);
      await localDataSource.updateVaccine(vaccineModel);
      return Right(vaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao atualizar vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final vaccineModels = await localDataSource.getVaccineHistory(
        animalId,
        startDate,
        endDate,
      );
      final vaccines = vaccineModels.map((model) => model.toEntity()).toList();
      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacinas por período: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVaccine(String id) async {
    try {
      await localDataSource.deleteVaccine(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir vacina: ${e.toString()}'));
    }
  }
}