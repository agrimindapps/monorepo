import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/defensivo.dart';
import '../../domain/repositories/defensivos_repository.dart';
import '../datasources/defensivos_remote_datasource.dart';
import '../models/defensivo_model.dart';

/// Implementation of DefensivosRepository
@LazySingleton(as: DefensivosRepository)
class DefensivosRepositoryImpl implements DefensivosRepository {
  final DefensivosRemoteDataSource remoteDataSource;

  const DefensivosRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Defensivo>>> getAllDefensivos() async {
    try {
      final models = await remoteDataSource.getAllDefensivos();

      // Convert models to entities
      final entities = models.map((model) => model as Defensivo).toList();

      return Right(entities);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Defensivo>> getDefensivoById(String id) async {
    try {
      // Validate ID
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      final model = await remoteDataSource.getDefensivoById(id);

      return Right(model as Defensivo);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Defensivo não encontrado'));
      }
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return const Left(NotFoundFailure('Defensivo não encontrado'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Defensivo>>> searchDefensivos(
    String query,
  ) async {
    try {
      // Validate query
      if (query.trim().isEmpty) {
        return const Left(ValidationFailure('Consulta de busca é obrigatória'));
      }

      final models = await remoteDataSource.searchDefensivos(query);

      // Convert models to entities
      final entities = models.map((model) => model as Defensivo).toList();

      return Right(entities);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Defensivo>> createDefensivo(Defensivo defensivo) async {
    try {
      // Validate required fields
      if (defensivo.nomeComum.trim().isEmpty) {
        return const Left(ValidationFailure('Nome comum é obrigatório'));
      }
      if (defensivo.fabricante.trim().isEmpty) {
        return const Left(ValidationFailure('Fabricante é obrigatório'));
      }
      if (defensivo.ingredienteAtivo.trim().isEmpty) {
        return const Left(ValidationFailure('Ingrediente ativo é obrigatório'));
      }

      final model = await remoteDataSource.createDefensivo(
        defensivo as DefensivoModel,
      );

      return Right(model as Defensivo);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Defensivo>> updateDefensivo(Defensivo defensivo) async {
    try {
      // Validate ID
      if (defensivo.id.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      // Validate required fields
      if (defensivo.nomeComum.trim().isEmpty) {
        return const Left(ValidationFailure('Nome comum é obrigatório'));
      }
      if (defensivo.fabricante.trim().isEmpty) {
        return const Left(ValidationFailure('Fabricante é obrigatório'));
      }
      if (defensivo.ingredienteAtivo.trim().isEmpty) {
        return const Left(ValidationFailure('Ingrediente ativo é obrigatório'));
      }

      final model = await remoteDataSource.updateDefensivo(
        defensivo as DefensivoModel,
      );

      return Right(model as Defensivo);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Defensivo não encontrado'));
      }
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return const Left(NotFoundFailure('Defensivo não encontrado'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDefensivo(String id) async {
    try {
      // Validate ID
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      await remoteDataSource.deleteDefensivo(id);

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
