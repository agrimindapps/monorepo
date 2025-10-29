import 'package:core/core.dart';
import '../entities/praga_entity.dart';
import '../repositories/i_pragas_repository.dart';
import 'get_pragas_params.dart';

/// Value Object para estatísticas
class PragasStats {
  final int insetos;
  final int doencas;
  final int plantas;
  final int total;

  const PragasStats({
    required this.insetos,
    required this.doencas,
    required this.plantas,
    required this.total,
  });

  factory PragasStats.fromMap(Map<String, int> map) {
    return PragasStats(
      insetos: map['insetos'] ?? 0,
      doencas: map['doencas'] ?? 0,
      plantas: map['plantas'] ?? 0,
      total: map['total'] ?? 0,
    );
  }

  double get percentualInsetos => total > 0 ? (insetos / total) * 100 : 0;
  double get percentualDoencas => total > 0 ? (doencas / total) * 100 : 0;
  double get percentualPlantas => total > 0 ? (plantas / total) * 100 : 0;

  @override
  String toString() {
    return 'PragasStats{insetos: $insetos, doencas: $doencas, plantas: $plantas, total: $total}';
  }
}

/// Use Case consolidado para buscar pragas
/// Consolida 7 usecases em 1 genérico com type-safe params
@injectable
class GetPragasUseCase {
  final IPragasRepository _repository;
  final IPragasHistoryRepository? _historyRepository;

  const GetPragasUseCase({
    required IPragasRepository repository,
    IPragasHistoryRepository? historyRepository,
  }) : _repository = repository,
       _historyRepository = historyRepository;

  /// Executa a busca baseado no tipo de parâmetro
  Future<Either<Failure, dynamic>> execute(GetPragasParams params) async {
    if (params is GetAllPragasParams) {
      return await _repository.getAll();
    }

    if (params is GetPragasByTipoParams) {
      if (params.tipo.isEmpty) {
        return const Left(ValidationFailure('Tipo não pode ser vazio'));
      }
      return await _repository.getByTipo(params.tipo);
    }

    if (params is GetPragaByIdParams) {
      if (params.id.isEmpty) {
        return const Left(ValidationFailure('ID não pode ser vazio'));
      }

      final result = await _repository.getById(params.id);
      await result.fold((failure) async => null, (praga) async {
        if (praga != null && _historyRepository != null) {
          await _historyRepository.markAsAccessed(params.id);
        }
      });

      return result;
    }

    if (params is GetPragasByCulturaParams) {
      if (params.culturaId.isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }
      return await _repository.getByCultura(params.culturaId);
    }

    if (params is SearchPragasParams) {
      if (params.searchTerm.trim().isEmpty) {
        return const Right<Failure, List<PragaEntity>>([]);
      }
      return await _repository.searchByName(params.searchTerm.trim());
    }

    if (params is GetRecentPragasParams) {
      if (_historyRepository == null) {
        return const Left(UnknownFailure('History repository não disponível'));
      }
      return await _historyRepository.getRecentlyAccessed();
    }

    if (params is GetSuggestedPragasParams) {
      if (_historyRepository == null) {
        return const Left(UnknownFailure('History repository não disponível'));
      }
      return await _historyRepository.getSuggested(params.limit);
    }

    if (params is GetPragasStatsParams) {
      final result = await _repository.getPragasStats();
      return result.map((stats) => PragasStats.fromMap(stats));
    }

    return const Left(
      UnknownFailure('Tipo de parâmetro desconhecido para GetPragasUseCase'),
    );
  }
}
