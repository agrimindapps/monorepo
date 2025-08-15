import '../entities/praga_entity.dart';
import '../repositories/i_pragas_repository.dart';

/// Use Case para buscar pragas (Domain Layer)
/// Princípios: Single Responsibility + Dependency Inversion
class GetPragasUseCase {
  final IPragasRepository _repository;

  const GetPragasUseCase({
    required IPragasRepository repository,
  }) : _repository = repository;

  /// Busca todas as pragas
  Future<List<PragaEntity>> execute() async {
    return await _repository.getAll();
  }
}

/// Use Case para buscar pragas por tipo
class GetPragasByTipoUseCase {
  final IPragasRepository _repository;

  const GetPragasByTipoUseCase({
    required IPragasRepository repository,
  }) : _repository = repository;

  Future<List<PragaEntity>> execute(String tipo) async {
    if (tipo.isEmpty) {
      throw ArgumentError('Tipo não pode ser vazio');
    }
    return await _repository.getByTipo(tipo);
  }
}

/// Use Case para buscar praga por ID
class GetPragaByIdUseCase {
  final IPragasRepository _repository;
  final IPragasHistoryRepository _historyRepository;

  const GetPragaByIdUseCase({
    required IPragasRepository repository,
    required IPragasHistoryRepository historyRepository,
  }) : _repository = repository,
       _historyRepository = historyRepository;

  Future<PragaEntity?> execute(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }

    final praga = await _repository.getById(id);
    
    // Marca como acessada se encontrada
    if (praga != null) {
      await _historyRepository.markAsAccessed(id);
    }
    
    return praga;
  }
}

/// Use Case para buscar pragas por cultura
class GetPragasByCulturaUseCase {
  final IPragasRepository _repository;

  const GetPragasByCulturaUseCase({
    required IPragasRepository repository,
  }) : _repository = repository;

  Future<List<PragaEntity>> execute(String culturaId) async {
    if (culturaId.isEmpty) {
      throw ArgumentError('ID da cultura não pode ser vazio');
    }
    return await _repository.getByCultura(culturaId);
  }
}

/// Use Case para pesquisar pragas por nome
class SearchPragasUseCase {
  final IPragasRepository _repository;

  const SearchPragasUseCase({
    required IPragasRepository repository,
  }) : _repository = repository;

  Future<List<PragaEntity>> execute(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }
    return await _repository.searchByName(searchTerm.trim());
  }
}

/// Use Case para obter pragas recentes
class GetRecentPragasUseCase {
  final IPragasHistoryRepository _historyRepository;

  const GetRecentPragasUseCase({
    required IPragasHistoryRepository historyRepository,
  }) : _historyRepository = historyRepository;

  Future<List<PragaEntity>> execute() async {
    return await _historyRepository.getRecentlyAccessed();
  }
}

/// Use Case para obter pragas sugeridas
class GetSuggestedPragasUseCase {
  final IPragasHistoryRepository _historyRepository;

  const GetSuggestedPragasUseCase({
    required IPragasHistoryRepository historyRepository,
  }) : _historyRepository = historyRepository;

  Future<List<PragaEntity>> execute({int limit = 5}) async {
    return await _historyRepository.getSuggested(limit);
  }
}

/// Use Case para obter estatísticas de pragas
class GetPragasStatsUseCase {
  final IPragasRepository _repository;

  const GetPragasStatsUseCase({
    required IPragasRepository repository,
  }) : _repository = repository;

  Future<PragasStats> execute() async {
    final futures = await Future.wait([
      _repository.getCountByTipo(PragaEntity.tipoInseto),
      _repository.getCountByTipo(PragaEntity.tipoDoenca),
      _repository.getCountByTipo(PragaEntity.tipoPlanta),
      _repository.getTotalCount(),
    ]);

    return PragasStats(
      insetos: futures[0],
      doencas: futures[1],
      plantas: futures[2],
      total: futures[3],
    );
  }
}

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

  double get percentualInsetos => total > 0 ? (insetos / total) * 100 : 0;
  double get percentualDoencas => total > 0 ? (doencas / total) * 100 : 0;
  double get percentualPlantas => total > 0 ? (plantas / total) * 100 : 0;

  @override
  String toString() {
    return 'PragasStats{insetos: $insetos, doencas: $doencas, plantas: $plantas, total: $total}';
  }
}