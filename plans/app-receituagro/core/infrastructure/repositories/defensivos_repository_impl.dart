// Project imports:
import '../../../repository/defensivos_repository.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/entities/defensivos_stats_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../../error/result.dart';
import '../mappers/defensivos_infrastructure_mapper.dart';

/// Implementação concreta do repositório de defensivos
/// 
/// Adapta o DefensivosRepository existente para a interface do domínio,
/// aplicando dependency inversion e isolando a camada de infraestrutura
class DefensivosRepositoryImpl implements IDefensivosRepository {
  late final DefensivosRepository _legacyRepository;
  final DefensivosInfrastructureMapper _mapper;

  DefensivosRepositoryImpl({DefensivosRepository? repository}) 
      : _mapper = DefensivosInfrastructureMapper() {
    _legacyRepository = repository ?? DefensivosRepository();
  }

  @override
  bool get isDataLoaded {
    try {
      // Verifica se o repository tem dados carregados
      final stats = _legacyRepository.getDefensivosCount();
      return stats > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<void>> initialize() async {
    try {
      // Inicializa o repository legado
      _legacyRepository.initInfo();
      
      // Aguarda o carregamento completo dos dados
      var attempts = 0;
      const maxAttempts = 10;
      
      while (!isDataLoaded && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'initialize',
          message: 'Timeout ao aguardar carregamento dos dados',
        ));
      }
      
      return Result.success(null);
      
    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'initialize',
        message: 'Erro na inicialização: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<DefensivosStatsEntity>> getDefensivosStats() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getDefensivosStats',
          message: 'Dados não foram carregados',
        ));
      }

      final stats = DefensivosStatsEntity(
        totalDefensivos: _legacyRepository.getDefensivosCount(),
        totalFabricantes: _legacyRepository.getFabricanteCount(),
        totalModosDeAcao: _legacyRepository.getModoDeAcaoCount(),
        totalIngredientesAtivos: _legacyRepository.getIngredienteAtivoCount(),
        totalClassesAgronomicas: _legacyRepository.getClasseAgronomicaCount(),
      );

      return Result.success(stats);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getDefensivosStats',
        message: 'Erro ao obter estatísticas: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<DefensivoEntity>>> getRecentlyAccessedDefensivos() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getRecentlyAccessedDefensivos',
          message: 'Dados não foram carregados',
        ));
      }

      final recentMaps = await _legacyRepository.getDefensivosAcessados();
      final entities = recentMaps
          .map((map) => _mapper.mapToEntity(map))
          .toList();

      return Result.success(entities);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getRecentlyAccessedDefensivos',
        message: 'Erro ao obter defensivos recentes: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<DefensivoEntity>>> getNewDefensivos() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getNewDefensivos',
          message: 'Dados não foram carregados',
        ));
      }

      final newMaps = _legacyRepository.getDefensivosNovos();
      final entities = newMaps
          .map((map) => _mapper.mapToEntity(map))
          .toList();

      return Result.success(entities);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getNewDefensivos',
        message: 'Erro ao obter defensivos novos: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<DefensivoEntity>> getDefensivoById(String id) async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getDefensivoById',
          message: 'Dados não foram carregados',
        ));
      }

      final defensivoMap = await _legacyRepository.getDefensivoById(id);
      if (defensivoMap.isEmpty) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getDefensivoById',
          message: 'Defensivo não encontrado: $id',
        ));
      }

      final entity = _mapper.mapToEntity(defensivoMap);
      return Result.success(entity);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getDefensivoById',
        message: 'Erro ao obter defensivo por ID: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<DefensivoEntity>>> getDefensivosByCategory(String category) async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getDefensivosByCategory',
          message: 'Dados não foram carregados',
        ));
      }

      // Esta funcionalidade precisaria ser implementada no repository legado
      // Por enquanto, retorno lista vazia
      return Result.success(<DefensivoEntity>[]);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getDefensivosByCategory',
        message: 'Erro ao obter defensivos por categoria: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> registerDefensivoAccess(String defensivoId) async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'registerDefensivoAccess',
          message: 'Dados não foram carregados',
        ));
      }

      _legacyRepository.setDefensivoAcessado(defensivoId: defensivoId);
      return Result.success(null);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'registerDefensivoAccess',
        message: 'Erro ao registrar acesso: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getClassesAgronomicas() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getClassesAgronomicas',
          message: 'Dados não foram carregados',
        ));
      }

      final classesMaps = _legacyRepository.getClasseAgronomica();
      final classes = classesMaps
          .map((map) => map['nome']?.toString() ?? '')
          .where((nome) => nome.isNotEmpty)
          .toList();

      return Result.success(classes);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getClassesAgronomicas',
        message: 'Erro ao obter classes agronômicas: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getFabricantes() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getFabricantes',
          message: 'Dados não foram carregados',
        ));
      }

      final fabricantesMaps = _legacyRepository.getFabricante();
      final fabricantes = fabricantesMaps
          .map((map) => map['nome']?.toString() ?? '')
          .where((nome) => nome.isNotEmpty)
          .toList();

      return Result.success(fabricantes);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getFabricantes',
        message: 'Erro ao obter fabricantes: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getModosDeAcao() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getModosDeAcao',
          message: 'Dados não foram carregados',
        ));
      }

      final modosMaps = _legacyRepository.getModoDeAcao();
      final modos = modosMaps
          .map((map) => map['nome']?.toString() ?? '')
          .where((nome) => nome.isNotEmpty)
          .toList();

      return Result.success(modos);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getModosDeAcao',
        message: 'Erro ao obter modos de ação: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getIngredientesAtivos() async {
    try {
      if (!isDataLoaded) {
        return Result.failure(RepositoryError(
          repositoryName: 'DefensivosRepository',
          operation: 'getIngredientesAtivos',
          message: 'Dados não foram carregados',
        ));
      }

      final ingredientesMaps = _legacyRepository.getIngredienteAtivo();
      final ingredientes = ingredientesMaps
          .map((map) => map['nome']?.toString() ?? '')
          .where((nome) => nome.isNotEmpty)
          .toList();

      return Result.success(ingredientes);

    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'getIngredientesAtivos',
        message: 'Erro ao obter ingredientes ativos: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void>> dispose() async {
    try {
      _legacyRepository.dispose();
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(RepositoryError(
        repositoryName: 'DefensivosRepository',
        operation: 'dispose',
        message: 'Erro ao fazer dispose: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}