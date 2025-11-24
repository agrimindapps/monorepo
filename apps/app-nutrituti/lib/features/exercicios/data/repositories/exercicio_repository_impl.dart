import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/exercicio_local_datasource.dart';
import '../../data/models/exercicio_model.dart';
import '../../domain/entities/exercicio.dart';
import '../../domain/repositories/exercicio_repository.dart';

class ExercicioRepositoryImpl implements ExercicioRepository {
  final ExercicioLocalDataSource _localDataSource;

  ExercicioRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Exercicio>>> getAllExercicios() async {
    try {
      final models = await _localDataSource.getAllExercicios();
      final entities = models
          .map(
            (model) => Exercicio(
              id: model.id,
              nome: model.nome,
              categoria: model.categoria,
              duracao: model.duracao,
              caloriasQueimadas: model.caloriasQueimadas,
              dataRegistro: model.dataRegistro,
              observacoes: model.observacoes,
            ),
          )
          .toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Exercicio?>> getExercicioById(String id) async {
    try {
      final model = await _localDataSource.getExercicioById(id);
      if (model == null) return const Right(null);

      final entity = Exercicio(
        id: model.id,
        nome: model.nome,
        categoria: model.categoria,
        duracao: model.duracao,
        caloriasQueimadas: model.caloriasQueimadas,
        dataRegistro: model.dataRegistro,
        observacoes: model.observacoes,
      );
      return Right(entity);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Exercicio>> addExercicio(Exercicio exercicio) async {
    try {
      final model = await _localDataSource.addExercicio(
        ExercicioModel(
          id: exercicio.id,
          nome: exercicio.nome,
          categoria: exercicio.categoria,
          duracao: exercicio.duracao,
          caloriasQueimadas: exercicio.caloriasQueimadas,
          dataRegistro: exercicio.dataRegistro,
          observacoes: exercicio.observacoes,
        ),
      );

      final entity = Exercicio(
        id: model.id,
        nome: model.nome,
        categoria: model.categoria,
        duracao: model.duracao,
        caloriasQueimadas: model.caloriasQueimadas,
        dataRegistro: model.dataRegistro,
        observacoes: model.observacoes,
      );
      return Right(entity);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Exercicio>> updateExercicio(
    Exercicio exercicio,
  ) async {
    try {
      final model = await _localDataSource.updateExercicio(
        ExercicioModel(
          id: exercicio.id,
          nome: exercicio.nome,
          categoria: exercicio.categoria,
          duracao: exercicio.duracao,
          caloriasQueimadas: exercicio.caloriasQueimadas,
          dataRegistro: exercicio.dataRegistro,
          observacoes: exercicio.observacoes,
        ),
      );

      final entity = Exercicio(
        id: model.id,
        nome: model.nome,
        categoria: model.categoria,
        duracao: model.duracao,
        caloriasQueimadas: model.caloriasQueimadas,
        dataRegistro: model.dataRegistro,
        observacoes: model.observacoes,
      );
      return Right(entity);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExercicio(String id) async {
    try {
      await _localDataSource.deleteExercicio(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Exercicio>>> getExerciciosByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await _localDataSource.getExerciciosByDateRange(
        start,
        end,
      );
      final entities = models
          .map(
            (model) => Exercicio(
              id: model.id,
              nome: model.nome,
              categoria: model.categoria,
              duracao: model.duracao,
              caloriasQueimadas: model.caloriasQueimadas,
              dataRegistro: model.dataRegistro,
              observacoes: model.observacoes,
            ),
          )
          .toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Exercicio>>> getExerciciosByCategoria(
    String categoria,
  ) async {
    try {
      final models = await _localDataSource.getExerciciosByCategoria(categoria);
      final entities = models
          .map(
            (model) => Exercicio(
              id: model.id,
              nome: model.nome,
              categoria: model.categoria,
              duracao: model.duracao,
              caloriasQueimadas: model.caloriasQueimadas,
              dataRegistro: model.dataRegistro,
              observacoes: model.observacoes,
            ),
          )
          .toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalCaloriasByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final total = await _localDataSource.getTotalCaloriasByDateRange(
        start,
        end,
      );
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncExercicios() async {
    // TODO: Implement sync with remote datasource when needed
    return const Right(null);
  }
}
