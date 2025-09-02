import 'package:dartz/dartz.dart';
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
    // Validação de entrada
    if (params.idDefensivo.isEmpty) {
      return const Left(
        ServerFailure('ID do defensivo é obrigatório'),
      );
    }

    try {
      final result = await _repository.getDiagnosticosByDefensivo(params.idDefensivo);
      
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          // Aplicar filtros se fornecidos
          var filteredDiagnosticos = diagnosticos;
          
          if (params.cultura != null && params.cultura!.isNotEmpty) {
            filteredDiagnosticos = filteredDiagnosticos
                .where((d) => d.cultura.toLowerCase() == params.cultura!.toLowerCase())
                .toList();
          }
          
          if (params.praga != null && params.praga!.isNotEmpty) {
            filteredDiagnosticos = filteredDiagnosticos
                .where((d) => d.grupo.toLowerCase().contains(params.praga!.toLowerCase()))
                .toList();
          }

          if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
            final query = params.searchQuery!.toLowerCase();
            filteredDiagnosticos = filteredDiagnosticos
                .where((d) => 
                  d.nome.toLowerCase().contains(query) ||
                  d.cultura.toLowerCase().contains(query) ||
                  d.grupo.toLowerCase().contains(query) ||
                  d.ingredienteAtivo.toLowerCase().contains(query))
                .toList();
          }
          
          // Ordenar por cultura e depois por nome
          filteredDiagnosticos.sort((a, b) {
            final culturaComparison = a.cultura.compareTo(b.cultura);
            if (culturaComparison != 0) return culturaComparison;
            return a.nome.compareTo(b.nome);
          });
          
          return Right(filteredDiagnosticos);
        },
      );
    } catch (e) {
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