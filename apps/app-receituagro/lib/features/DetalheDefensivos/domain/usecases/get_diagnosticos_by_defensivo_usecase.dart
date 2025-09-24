import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/diagnostico_entity.dart';
import '../repositories/diagnostico_repository.dart';

/// Caso de uso para buscar diagnósticos por defensivo
/// 
/// Este use case encapsula a lógica de negócio para buscar
/// diagnósticos relacionados a um defensivo específico
class GetDiagnosticosByDefensivoUseCase implements UseCase<List<DiagnosticoEntity>, GetDiagnosticosByDefensivoParams> {
  const GetDiagnosticosByDefensivoUseCase(this._repository);

  final DiagnosticoRepository _repository;

  @override
  ResultFuture<List<DiagnosticoEntity>> call(GetDiagnosticosByDefensivoParams params) async {
    debugPrint('=== USE CASE: Iniciando busca de diagnósticos ===');
    debugPrint('Parâmetros recebidos:');
    debugPrint('  - ID Defensivo: ${params.idDefensivo}');
    debugPrint('  - Cultura: ${params.cultura ?? 'null'}');
    debugPrint('  - Praga: ${params.praga ?? 'null'}');
    debugPrint('  - Search Query: ${params.searchQuery ?? 'null'}');
    debugPrint('  - Parâmetros válidos: ${params.isValid}');

    // Validação de entrada
    if (params.idDefensivo.isEmpty) {
      debugPrint('❌ ERRO: ID do defensivo está vazio');
      return const Left(
        ServerFailure('ID do defensivo é obrigatório'),
      );
    }

    try {
      debugPrint('Chamando repository.getDiagnosticosByDefensivo...');
      final repositoryStartTime = DateTime.now();
      final result = await _repository.getDiagnosticosByDefensivo(params.idDefensivo);
      final repositoryEndTime = DateTime.now();
      final repositoryDuration = repositoryEndTime.difference(repositoryStartTime);
      
      debugPrint('Tempo no repository: ${repositoryDuration.inMilliseconds}ms');
      
      return result.fold(
        (failure) {
          debugPrint('❌ FALHA no repository: ${failure.message}');
          return Left(failure);
        },
        (diagnosticos) {
          debugPrint('✅ SUCESSO no repository');
          debugPrint('Diagnósticos brutos encontrados: ${diagnosticos.length}');
          
          // Aplicar filtros se fornecidos
          var filteredDiagnosticos = diagnosticos;
          debugPrint('=== APLICANDO FILTROS ===');
          
          if (params.cultura != null && params.cultura!.isNotEmpty) {
            final beforeCulturaFilter = filteredDiagnosticos.length;
            filteredDiagnosticos = filteredDiagnosticos
                .where((d) => d.cultura.toLowerCase() == params.cultura!.toLowerCase())
                .toList();
            debugPrint('Filtro cultura "${params.cultura}": $beforeCulturaFilter → ${filteredDiagnosticos.length}');
          }
          
          if (params.praga != null && params.praga!.isNotEmpty) {
            final beforePragaFilter = filteredDiagnosticos.length;
            filteredDiagnosticos = filteredDiagnosticos
                .where((d) => d.grupo.toLowerCase().contains(params.praga!.toLowerCase()))
                .toList();
            debugPrint('Filtro praga "${params.praga}": $beforePragaFilter → ${filteredDiagnosticos.length}');
          }

          if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
            final beforeSearchFilter = filteredDiagnosticos.length;
            final query = params.searchQuery!.toLowerCase();
            filteredDiagnosticos = filteredDiagnosticos
                .where((d) => 
                  d.nome.toLowerCase().contains(query) ||
                  d.cultura.toLowerCase().contains(query) ||
                  d.grupo.toLowerCase().contains(query) ||
                  d.ingredienteAtivo.toLowerCase().contains(query))
                .toList();
            debugPrint('Filtro busca "$query": $beforeSearchFilter → ${filteredDiagnosticos.length}');
          }
          
          // Ordenar por cultura e depois por nome
          debugPrint('Ordenando diagnósticos...');
          filteredDiagnosticos.sort((a, b) {
            final culturaComparison = a.cultura.compareTo(b.cultura);
            if (culturaComparison != 0) return culturaComparison;
            return a.nome.compareTo(b.nome);
          });
          
          debugPrint('=== RESULTADO FINAL ===');
          debugPrint('Diagnósticos retornados: ${filteredDiagnosticos.length}');
          
          return Right(filteredDiagnosticos);
        },
      );
    } catch (e) {
      debugPrint('❌ EXCEÇÃO no UseCase: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return Left(ServerFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }
}

/// Parâmetros para buscar diagnósticos por defensivo
class GetDiagnosticosByDefensivoParams {
  final String idDefensivo;
  final String? cultura;
  final String? praga;
  final String? searchQuery;

  const GetDiagnosticosByDefensivoParams({
    required this.idDefensivo,
    this.cultura,
    this.praga,
    this.searchQuery,
  });

  /// Valida se os parâmetros são válidos
  bool get isValid => idDefensivo.isNotEmpty;
}