import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../../diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/diagnostico_repository.dart';
import '../models/diagnostico_model.dart';

/// Implementação do repositório de diagnósticos
/// 
/// Esta classe implementa o contrato definido no domain layer,
/// usando o DiagnosticosRepositoryImpl como fonte de dados
class DiagnosticoRepositoryImpl implements DiagnosticoRepository {
  const DiagnosticoRepositoryImpl(this._diagnosticosRepository);

  final DiagnosticosRepositoryImpl _diagnosticosRepository;

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByDefensivo(String idDefensivo) async {
    try {
      final result = await _diagnosticosRepository.getByDefensivo(idDefensivo);
      
      return result.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final models = diagnosticosEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();
          return Right(models);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar diagnósticos por defensivo: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByCultura(String cultura) async {
    try {
      final allResult = await _diagnosticosRepository.getAll();
      
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final filteredEntities = diagnosticosEntities
              .where((entity) => 
                  entity.nomeCultura?.toLowerCase() == cultura.toLowerCase())
              .toList();
          
          final models = filteredEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();
          
          return Right(models);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar diagnósticos por cultura: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByPraga(String praga) async {
    try {
      final allResult = await _diagnosticosRepository.getAll();
      
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final filteredEntities = diagnosticosEntities
              .where((entity) => 
                  entity.nomePraga?.toLowerCase().contains(praga.toLowerCase()) == true)
              .toList();
          
          final models = filteredEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();
          
          return Right(models);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar diagnósticos por praga: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<DiagnosticoEntity> getDiagnosticoById(String id) async {
    try {
      final allResult = await _diagnosticosRepository.getAll();
      
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final entity = diagnosticosEntities
              .where((entity) => entity.id == id)
              .firstOrNull;
          
          if (entity == null) {
            return Left(CacheFailure('Diagnóstico não encontrado com ID: $id'));
          }
          
          final model = DiagnosticoModel.fromDiagnosticsEntity(entity);
          return Right(model);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar diagnóstico por ID: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticos({
    String? cultura,
    String? praga,
    String? defensivo,
    int? limit,
    int? offset,
  }) async {
    try {
      final allResult = await _diagnosticosRepository.getAll();
      
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          var filteredEntities = diagnosticosEntities;
          
          // Aplicar filtros
          if (cultura != null && cultura.isNotEmpty) {
            filteredEntities = filteredEntities
                .where((entity) => 
                    entity.nomeCultura?.toLowerCase() == cultura.toLowerCase())
                .toList();
          }
          
          if (praga != null && praga.isNotEmpty) {
            filteredEntities = filteredEntities
                .where((entity) => 
                    entity.nomePraga?.toLowerCase().contains(praga.toLowerCase()) == true)
                .toList();
          }
          
          if (defensivo != null && defensivo.isNotEmpty) {
            filteredEntities = filteredEntities
                .where((entity) => 
                    entity.nomeDefensivo?.toLowerCase().contains(defensivo.toLowerCase()) == true)
                .toList();
          }
          
          // Aplicar paginação
          if (offset != null && offset > 0) {
            if (offset >= filteredEntities.length) {
              return const Right([]);
            }
            filteredEntities = filteredEntities.skip(offset).toList();
          }
          
          if (limit != null && limit > 0) {
            filteredEntities = filteredEntities.take(limit).toList();
          }
          
          final models = filteredEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();
          
          return Right(models);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DiagnosticoEntity>> searchDiagnosticos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final searchQuery = query.toLowerCase();
      final allResult = await _diagnosticosRepository.getAll();
      
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final filteredEntities = diagnosticosEntities
              .where((entity) => 
                  entity.nomeDefensivo?.toLowerCase().contains(searchQuery) == true ||
                  entity.nomeCultura?.toLowerCase().contains(searchQuery) == true ||
                  entity.nomePraga?.toLowerCase().contains(searchQuery) == true)
              .toList();
          
          final models = filteredEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();
          
          // Ordenar por relevância
          models.sort((a, b) {
            final aNameMatch = a.nomeDefensivo?.toLowerCase().contains(searchQuery) == true;
            final bNameMatch = b.nomeDefensivo?.toLowerCase().contains(searchQuery) == true;
            
            if (aNameMatch && !bNameMatch) return -1;
            if (!aNameMatch && bNameMatch) return 1;
            return (a.nomeDefensivo ?? '').compareTo(b.nomeDefensivo ?? '');
          });
          
          return Right(models);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao pesquisar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  Stream<List<DiagnosticoEntity>> watchDiagnosticos() async* {
    try {
      // Como não temos stream nativo, simulamos com refresh periódico
      while (true) {
        final allResult = await _diagnosticosRepository.getAll();
        
        await for (final result in Stream.value(allResult)) {
          yield result.fold(
            (failure) => [],
            (diagnosticosEntities) => diagnosticosEntities
                .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
                .toList(),
          );
        }
        
        // Aguarda 10 segundos antes do próximo refresh
        await Future<void>.delayed(const Duration(seconds: 10));
      }
    } catch (e) {
      yield [];
    }
  }
}