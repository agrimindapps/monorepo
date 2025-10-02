import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/typedef.dart';
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/diagnostico_repository.dart';
import '../models/diagnostico_model.dart';

/// Implementação do repositório de diagnósticos
/// 
/// Esta classe implementa o contrato definido no domain layer,
/// usando o IDiagnosticosRepository como fonte de dados
class DiagnosticoRepositoryImpl implements DiagnosticoRepository {
  const DiagnosticoRepositoryImpl(this._diagnosticosRepository);

  final IDiagnosticosRepository _diagnosticosRepository;

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByDefensivo(String idDefensivo) async {
    try {
      debugPrint('=== REPOSITORY IMPL: getDiagnosticosByDefensivo ===');
      debugPrint('ID Defensivo recebido: $idDefensivo');
      
      final repositoryStartTime = DateTime.now();
      final result = await _diagnosticosRepository.getByDefensivo(idDefensivo);
      final repositoryEndTime = DateTime.now();
      final duration = repositoryEndTime.difference(repositoryStartTime);
      
      debugPrint('Tempo na chamada _diagnosticosRepository.getByDefensivo: ${duration.inMilliseconds}ms');
      
      return result.fold(
        (failure) {
          debugPrint('❌ FALHA no _diagnosticosRepository: ${failure.message}');
          return Left(failure);
        },
        (diagnosticosEntities) {
          debugPrint('✅ SUCESSO no _diagnosticosRepository');
          debugPrint('Entidades brutas encontradas: ${diagnosticosEntities.length}');
          
          // Log das primeiras entidades para debug
          if (diagnosticosEntities.isNotEmpty) {
            debugPrint('=== ENTIDADES ENCONTRADAS (primeiras 3) ===');
            for (int i = 0; i < diagnosticosEntities.length && i < 3; i++) {
              final entity = diagnosticosEntities[i];
              debugPrint('[$i] ID: ${entity.id}');
              debugPrint('[$i] idDefensivo: ${entity.idDefensivo}');
              debugPrint('[$i] nomeDefensivo: ${entity.nomeDefensivo}');
              debugPrint('[$i] nomeCultura: ${entity.nomeCultura}');
              debugPrint('[$i] nomePraga: ${entity.nomePraga}');
              debugPrint('---');
            }
          }
          
          final conversionStartTime = DateTime.now();
          final models = diagnosticosEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();
          final conversionEndTime = DateTime.now();
          final conversionDuration = conversionEndTime.difference(conversionStartTime);
          
          debugPrint('Conversão para models: ${conversionDuration.inMilliseconds}ms');
          debugPrint('Models finais: ${models.length}');
          
          return Right(models);
        },
      );
    } catch (e) {
      debugPrint('❌ EXCEÇÃO no Repository Impl: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return Left(ServerFailure('Erro ao buscar diagnósticos por defensivo: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<DiagnosticoEntity>> getDiagnosticosByCultura(String cultura) async {
    try {
      // ✅ CORRETO: Usar idCultura para filtrar, não nomeCultura cached
      final allResult = await _diagnosticosRepository.getByCultura(cultura);

      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final models = diagnosticosEntities
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
      // ✅ CORRETO: Usar idPraga para filtrar, não nomePraga cached
      final allResult = await _diagnosticosRepository.getByPraga(praga);

      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          final models = diagnosticosEntities
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
      // ✅ CORRETO: Usar repository methods que filtram por IDs, não por nomes cached
      var result = await _diagnosticosRepository.getAll();

      // Aplicar filtros usando os métodos corretos do repository
      if (cultura != null && cultura.isNotEmpty) {
        result = await _diagnosticosRepository.getByCultura(cultura);
      } else if (praga != null && praga.isNotEmpty) {
        result = await _diagnosticosRepository.getByPraga(praga);
      } else if (defensivo != null && defensivo.isNotEmpty) {
        result = await _diagnosticosRepository.getByDefensivo(defensivo);
      }

      return result.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          var filteredEntities = diagnosticosEntities;

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

      // ⚠️ NOTA: Search por texto livre requer resolver IDs para nomes
      // Por ora, delegamos para o repository que usa IDs
      // TODO: Implementar busca full-text após resolução de nomes
      debugPrint('⚠️ searchDiagnosticos: Busca por texto livre pode retornar resultados incompletos');
      debugPrint('   Recomenda-se usar filtros específicos por ID (cultura/praga/defensivo)');

      final allResult = await _diagnosticosRepository.getAll();

      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticosEntities) {
          // Por enquanto, retorna todos e deixa a UI filtrar após resolução
          // Isso garante que nenhum resultado válido seja perdido
          final models = diagnosticosEntities
              .map((entity) => DiagnosticoModel.fromDiagnosticsEntity(entity))
              .toList();

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