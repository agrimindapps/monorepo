import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/diagnostico.dart';
import '../../domain/repositories/diagnosticos_repository.dart';
import '../datasources/diagnosticos_remote_datasource.dart';
import '../models/diagnostico_model.dart';

/// Implementation of DiagnosticosRepository
class DiagnosticosRepositoryImpl implements DiagnosticosRepository {
  final DiagnosticosRemoteDataSource remoteDataSource;

  const DiagnosticosRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Diagnostico>>> getDiagnosticosByDefensivoId(
    String defensivoId,
  ) async {
    try {
      // Validate ID
      if (defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      final models = await remoteDataSource.getDiagnosticosByDefensivoId(
        defensivoId,
      );

      // Convert models to entities
      final entities = models.map((model) => model as Diagnostico).toList();

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
  Future<Either<Failure, Diagnostico>> getDiagnosticoById(String id) async {
    try {
      // Validate ID
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID do diagnóstico é obrigatório'));
      }

      final model = await remoteDataSource.getDiagnosticoById(id);

      return Right(model as Diagnostico);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Diagnóstico não encontrado'));
      }
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return const Left(NotFoundFailure('Diagnóstico não encontrado'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Diagnostico>> createDiagnostico(
    Diagnostico diagnostico,
  ) async {
    try {
      // Validate required fields
      if (diagnostico.defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }
      if (diagnostico.culturaId.trim().isEmpty) {
        return const Left(ValidationFailure('ID da cultura é obrigatório'));
      }
      if (diagnostico.pragaId.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga é obrigatório'));
      }

      final model = await remoteDataSource.createDiagnostico(
        diagnostico as DiagnosticoModel,
      );

      return Right(model as Diagnostico);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Diagnostico>> updateDiagnostico(
    Diagnostico diagnostico,
  ) async {
    try {
      // Validate ID
      if (diagnostico.id.trim().isEmpty) {
        return const Left(ValidationFailure('ID do diagnóstico é obrigatório'));
      }

      // Validate required fields
      if (diagnostico.defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }
      if (diagnostico.culturaId.trim().isEmpty) {
        return const Left(ValidationFailure('ID da cultura é obrigatório'));
      }
      if (diagnostico.pragaId.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga é obrigatório'));
      }

      final model = await remoteDataSource.updateDiagnostico(
        diagnostico as DiagnosticoModel,
      );

      return Right(model as Diagnostico);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Diagnóstico não encontrado'));
      }
      return Left(ServerFailure('Erro no servidor: ${e.message}'));
    } on Exception catch (e) {
      if (e.toString().contains('não encontrado')) {
        return const Left(NotFoundFailure('Diagnóstico não encontrado'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(UnexpectedFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDiagnostico(String id) async {
    try {
      // Validate ID
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID do diagnóstico é obrigatório'));
      }

      await remoteDataSource.deleteDiagnostico(id);

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
  Future<Either<Failure, Unit>> deleteDiagnosticosByDefensivoId(
    String defensivoId,
  ) async {
    try {
      // Validate ID
      if (defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo é obrigatório'));
      }

      await remoteDataSource.deleteDiagnosticosByDefensivoId(defensivoId);

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
