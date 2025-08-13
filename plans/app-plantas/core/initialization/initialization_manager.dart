// Dart imports:
import 'dart:async';

/// Estados possíveis de inicialização
enum InitializationStatus {
  notStarted,
  initializing,
  completed,
  failed,
  timeout,
}

/// Resultado de inicialização
class InitializationResult {
  final String repositoryName;
  final InitializationStatus status;
  final DateTime timestamp;
  final Duration duration;
  final String? error;
  final List<String> dependencies;

  const InitializationResult({
    required this.repositoryName,
    required this.status,
    required this.timestamp,
    required this.duration,
    this.error,
    this.dependencies = const [],
  });

  bool get isSuccess => status == InitializationStatus.completed;
  bool get isFailure =>
      status == InitializationStatus.failed ||
      status == InitializationStatus.timeout;
}

/// Configuração de inicialização para um repository
class RepositoryConfig {
  final String name;
  final List<String> dependencies;
  final Duration timeout;
  final int maxRetries;
  final Duration retryDelay;
  final Future<void> Function() initFunction;

  const RepositoryConfig({
    required this.name,
    required this.initFunction,
    this.dependencies = const [],
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
  });
}

/// Gerenciador centralizado para inicialização de repositories
/// Resolve race conditions e controla ordem de dependências
class InitializationManager {
  static InitializationManager? _instance;
  static InitializationManager get instance =>
      _instance ??= InitializationManager._();

  InitializationManager._();

  // Estado global de inicialização
  final Map<String, InitializationStatus> _status = {};
  final Map<String, Completer<InitializationResult>> _completers = {};
  final Map<String, RepositoryConfig> _configs = {};
  final Map<String, InitializationResult> _results = {};
  final Map<String, DateTime> _startTimes = {};

  // Cache para evitar recriação de dependency graph
  List<String>? _cachedInitializationOrder;

  /// Registrar configuração de um repository
  void registerRepository(RepositoryConfig config) {
    _configs[config.name] = config;
    _status[config.name] = InitializationStatus.notStarted;

    // Invalidar cache da ordem de inicialização
    _cachedInitializationOrder = null;
  }

  /// Inicializar um repository específico (thread-safe com Completer)
  Future<InitializationResult> initializeRepository(
      String repositoryName) async {
    // Verificar se já foi inicializado com sucesso
    if (_status[repositoryName] == InitializationStatus.completed) {
      return _results[repositoryName]!;
    }

    // Verificar se já está sendo inicializado - aguardar completion
    if (_status[repositoryName] == InitializationStatus.initializing) {
      return await _completers[repositoryName]!.future;
    }

    // Verificar se configuração existe
    final config = _configs[repositoryName];
    if (config == null) {
      throw ArgumentError('Repository $repositoryName não foi registrado');
    }

    // Inicializar dependências primeiro
    await _initializeDependencies(config.dependencies);

    // Marcar como inicializando e criar completer
    _status[repositoryName] = InitializationStatus.initializing;
    _startTimes[repositoryName] = DateTime.now();
    _completers[repositoryName] = Completer<InitializationResult>();

    try {
      // Executar inicialização com timeout e retry
      await _executeWithTimeoutAndRetry(config);

      // Sucesso
      final result = InitializationResult(
        repositoryName: repositoryName,
        status: InitializationStatus.completed,
        timestamp: DateTime.now(),
        duration: DateTime.now().difference(_startTimes[repositoryName]!),
        dependencies: config.dependencies,
      );

      _status[repositoryName] = InitializationStatus.completed;
      _results[repositoryName] = result;
      _completers[repositoryName]!.complete(result);

      return result;
    } catch (e) {
      // Falha
      final status = e is TimeoutException
          ? InitializationStatus.timeout
          : InitializationStatus.failed;

      final result = InitializationResult(
        repositoryName: repositoryName,
        status: status,
        timestamp: DateTime.now(),
        duration: DateTime.now().difference(_startTimes[repositoryName]!),
        error: e.toString(),
        dependencies: config.dependencies,
      );

      _status[repositoryName] = status;
      _results[repositoryName] = result;
      _completers[repositoryName]!.complete(result);

      throw Exception('Falha na inicialização de $repositoryName: $e');
    }
  }

  /// Inicializar múltiplos repositories respeitando dependências
  Future<Map<String, InitializationResult>> initializeAll({
    List<String>? repositories,
  }) async {
    final reposToInit = repositories ?? _configs.keys.toList();
    final results = <String, InitializationResult>{};

    // Calcular ordem de inicialização baseada em dependências
    final initOrder = _calculateInitializationOrder(reposToInit);

    for (final repoName in initOrder) {
      try {
        results[repoName] = await initializeRepository(repoName);
      } catch (e) {
        // Continuar com outros repositories mesmo se um falhar
        continue;
      }
    }

    return results;
  }

  /// Verificar se repository está inicializado
  bool isInitialized(String repositoryName) {
    return _status[repositoryName] == InitializationStatus.completed;
  }

  /// Verificar se repository está sendo inicializado
  bool isInitializing(String repositoryName) {
    return _status[repositoryName] == InitializationStatus.initializing;
  }

  /// Verificar se repository falhou na inicialização
  bool hasFailed(String repositoryName) {
    final status = _status[repositoryName];
    return status == InitializationStatus.failed ||
        status == InitializationStatus.timeout;
  }

  /// Obter status de um repository
  InitializationStatus getStatus(String repositoryName) {
    return _status[repositoryName] ?? InitializationStatus.notStarted;
  }

  /// Obter resultado de inicialização
  InitializationResult? getResult(String repositoryName) {
    return _results[repositoryName];
  }

  /// Aguardar inicialização de um repository (se estiver em progresso)
  Future<InitializationResult> waitForInitialization(
      String repositoryName) async {
    if (_status[repositoryName] == InitializationStatus.completed) {
      return _results[repositoryName]!;
    }

    if (_status[repositoryName] == InitializationStatus.initializing) {
      return await _completers[repositoryName]!.future;
    }

    throw StateError('Repository $repositoryName não está sendo inicializado');
  }

  /// Reinicializar repository (força nova inicialização)
  Future<InitializationResult> reinitialize(String repositoryName) async {
    _status[repositoryName] = InitializationStatus.notStarted;
    _completers.remove(repositoryName);
    _results.remove(repositoryName);
    _startTimes.remove(repositoryName);

    return await initializeRepository(repositoryName);
  }

  /// Obter estatísticas de inicialização
  Map<String, dynamic> getStatistics() {
    final stats = {
      'total_repositories': _configs.length,
      'initialized': _status.values
          .where((s) => s == InitializationStatus.completed)
          .length,
      'initializing': _status.values
          .where((s) => s == InitializationStatus.initializing)
          .length,
      'failed': _status.values
          .where((s) =>
              s == InitializationStatus.failed ||
              s == InitializationStatus.timeout)
          .length,
      'not_started': _status.values
          .where((s) => s == InitializationStatus.notStarted)
          .length,
      'repositories': <String, Map<String, dynamic>>{},
    };

    for (final entry in _status.entries) {
      final result = _results[entry.key];
      final repositories =
          stats['repositories'] as Map<String, Map<String, dynamic>>;
      repositories[entry.key] = {
        'status': entry.value.toString(),
        'duration_ms': result?.duration.inMilliseconds,
        'error': result?.error,
        'dependencies': _configs[entry.key]?.dependencies ?? [],
      };
    }

    return stats;
  }

  /// Limpar estado (útil para testes)
  void reset() {
    _status.clear();
    _completers.clear();
    _configs.clear();
    _results.clear();
    _startTimes.clear();
    _cachedInitializationOrder = null;
  }

  // Métodos privados

  /// Inicializar dependências recursivamente
  Future<void> _initializeDependencies(List<String> dependencies) async {
    for (final dependency in dependencies) {
      if (!isInitialized(dependency)) {
        await initializeRepository(dependency);
      }
    }
  }

  /// Executar inicialização com timeout e retry
  Future<void> _executeWithTimeoutAndRetry(RepositoryConfig config) async {
    Exception? lastException;

    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        await config.initFunction().timeout(config.timeout);
        return; // Sucesso
      } on TimeoutException {
        lastException = TimeoutException(
          'Timeout na inicialização de ${config.name} após ${config.timeout}',
        );
      } catch (e) {
        lastException =
            Exception('Erro na inicialização de ${config.name}: $e');
      }

      // Se não é a última tentativa, aguardar antes de tentar novamente
      if (attempt < config.maxRetries) {
        final delay = Duration(
          milliseconds: config.retryDelay.inMilliseconds * (attempt + 1),
        );
        await Future.delayed(delay);
      }
    }

    // Se chegou aqui, todas as tentativas falharam
    throw lastException!;
  }

  /// Calcular ordem de inicialização usando topological sort
  List<String> _calculateInitializationOrder(List<String> repositories) {
    // Usar cache se disponível
    if (_cachedInitializationOrder != null &&
        _cachedInitializationOrder!.toSet().containsAll(repositories)) {
      return _cachedInitializationOrder!
          .where((repo) => repositories.contains(repo))
          .toList();
    }

    final visited = <String>{};
    final visiting = <String>{};
    final result = <String>[];

    void visit(String repo) {
      if (visiting.contains(repo)) {
        throw Exception('Dependência circular detectada envolvendo $repo');
      }

      if (visited.contains(repo)) {
        return;
      }

      visiting.add(repo);

      final config = _configs[repo];
      if (config != null) {
        for (final dependency in config.dependencies) {
          if (repositories.contains(dependency)) {
            visit(dependency);
          }
        }
      }

      visiting.remove(repo);
      visited.add(repo);
      result.add(repo);
    }

    for (final repo in repositories) {
      if (!visited.contains(repo)) {
        visit(repo);
      }
    }

    // Cache do resultado
    _cachedInitializationOrder = List.from(result);

    return result;
  }
}

/// Classe auxiliar para configuração de repositories comuns
class CommonRepositoryConfigs {
  static RepositoryConfig espacoRepository(
      Future<void> Function() initFunction) {
    return RepositoryConfig(
      name: 'EspacoRepository',
      initFunction: initFunction,
      dependencies: [], // Não tem dependências
      timeout: const Duration(seconds: 10),
      maxRetries: 2,
    );
  }

  static RepositoryConfig plantaRepository(
      Future<void> Function() initFunction) {
    return RepositoryConfig(
      name: 'PlantaRepository',
      initFunction: initFunction,
      dependencies: ['EspacoRepository'], // Depende de EspacoRepository
      timeout: const Duration(seconds: 15),
      maxRetries: 3,
    );
  }

  static RepositoryConfig plantaConfigRepository(
      Future<void> Function() initFunction) {
    return RepositoryConfig(
      name: 'PlantaConfigRepository',
      initFunction: initFunction,
      dependencies: ['PlantaRepository'], // Depende de PlantaRepository
      timeout: const Duration(seconds: 10),
      maxRetries: 2,
    );
  }

  static RepositoryConfig tarefaRepository(
      Future<void> Function() initFunction) {
    return RepositoryConfig(
      name: 'TarefaRepository',
      initFunction: initFunction,
      dependencies: ['PlantaRepository'], // Depende de PlantaRepository
      timeout: const Duration(seconds: 10),
      maxRetries: 2,
    );
  }
}
