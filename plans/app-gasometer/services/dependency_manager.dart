// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../repository/abastecimentos_repository.dart';
import '../repository/despesas_repository.dart';
import '../repository/manutecoes_repository.dart';
import '../repository/odometro_repository.dart';
import '../repository/veiculos_repository.dart';
import '../services/gasometer_subscription_service.dart';

/// Gerenciador de dependências thread-safe para o módulo Gasometer
/// 
/// Resolve race conditions na inicialização através de:
/// - Completer para garantir inicialização única
/// - Dependency graph explícito para ordem correta
/// - Estados de inicialização bem definidos
/// - Thread-safety com locks
class DependencyManager {
  static final DependencyManager _instance = DependencyManager._();
  static DependencyManager get instance => _instance;
  
  DependencyManager._();

  // Estados de inicialização
  static const String _stateUninitialized = 'uninitialized';
  static const String _stateInitializing = 'initializing';
  static const String _stateInitialized = 'initialized';
  static const String _stateError = 'error';

  String _initializationState = _stateUninitialized;
  Completer<void>? _initializationCompleter;
  Object? _initializationError;

  /// Dependency graph explícito definindo ordem de inicialização
  static const Map<String, List<String>> _dependencyGraph = {
    // Level 0: Sem dependências - Adaptadores Hive
    'hive_adapters': [],
    
    // Level 1: Repositórios base - dependem apenas de adaptadores
    'veiculos_repository': ['hive_adapters'],
    'abastecimentos_repository': ['hive_adapters'],
    'odometro_repository': ['hive_adapters'],
    'manutecoes_repository': ['hive_adapters'],
    'despesas_repository': ['hive_adapters'],
    
    // Level 2: Services - dependem de repositórios
    'gasometer_subscription_service': [
      'veiculos_repository',
      'abastecimentos_repository',
    ],
    
    // Level 3: GetX Bindings - dependem de tudo
    'getx_bindings': [
      'veiculos_repository',
      'abastecimentos_repository',
      'odometro_repository', 
      'manutecoes_repository',
      'despesas_repository',
      'gasometer_subscription_service',
    ],
  };

  /// Inicializa todas as dependências de forma thread-safe
  /// 
  /// Garante que apenas uma inicialização ocorra mesmo com
  /// múltiplas chamadas simultâneas
  Future<void> initializeAll() async {
    // Se já está inicializado, retorna imediatamente
    if (_initializationState == _stateInitialized) {
      return;
    }

    // Se está inicializando, aguarda a inicialização atual
    if (_initializationState == _stateInitializing) {
      await _initializationCompleter!.future;
      return;
    }

    // Se houve erro anterior, re-throw o erro
    if (_initializationState == _stateError) {
      throw _initializationError!;
    }

    // Inicia nova inicialização
    _initializationState = _stateInitializing;
    _initializationCompleter = Completer<void>();

    try {
      await _performInitialization();
      _initializationState = _stateInitialized;
      _initializationCompleter!.complete();
    } catch (error) {
      _initializationState = _stateError;
      _initializationError = error;
      _initializationCompleter!.completeError(error);
      rethrow;
    }
  }

  /// Valida se múltiplas inicializações simultâneas funcionam corretamente
  /// 
  /// Este método pode ser chamado em produção para validar o sistema
  Future<void> validateConcurrentSafety() async {
    // Cria múltiplas inicializações simultâneas
    final futures = List.generate(3, (_) => initializeAll());
    
    // Todas devem completar sem erro
    await Future.wait(futures);
    
    // Verifica se está inicializado
    if (!isInitialized) {
      throw StateError('Concurrent initialization validation failed');
    }
  }

  /// Executa a inicialização seguindo o dependency graph
  Future<void> _performInitialization() async {
    // Resolve ordem de inicialização usando topological sort
    final initializationOrder = _resolveDependencyOrder();
    
    // Inicializa componentes em ordem sequencial
    for (final component in initializationOrder) {
      await _initializeComponent(component);
    }
  }

  /// Resolve a ordem de inicialização usando topological sort
  List<String> _resolveDependencyOrder() {
    final visited = <String>{};
    final visiting = <String>{};
    final result = <String>[];

    void visit(String node) {
      if (visited.contains(node)) return;
      
      if (visiting.contains(node)) {
        throw StateError('Circular dependency detected involving: $node');
      }

      visiting.add(node);
      
      final dependencies = _dependencyGraph[node] ?? [];
      for (final dependency in dependencies) {
        visit(dependency);
      }
      
      visiting.remove(node);
      visited.add(node);
      result.add(node);
    }

    // Visita todos os nós do grafo
    for (final component in _dependencyGraph.keys) {
      visit(component);
    }

    return result;
  }

  /// Inicializa um componente específico
  Future<void> _initializeComponent(String component) async {
    try {
      switch (component) {
        case 'hive_adapters':
          await _initializeHiveAdapters();
          break;
          
        case 'veiculos_repository':
          await VeiculosRepository.initialize();
          break;
          
        case 'abastecimentos_repository':
          await AbastecimentosRepository.initialize();
          break;
          
        case 'odometro_repository':
          await OdometroRepository.initialize();
          break;
          
        case 'manutecoes_repository':
          await ManutencoesRepository.initialize();
          break;
          
        case 'despesas_repository':
          // DespesasRepository não tem método static initialize
          // A inicialização será feita quando a instância for criada
          break;
          
        case 'gasometer_subscription_service':
          await _initializeGasometerService();
          break;
          
        case 'getx_bindings':
          await _initializeGetXBindings();
          break;
          
        default:
          debugPrint('Unknown component in dependency graph: $component');
      }
    } catch (error) {
      debugPrint('Error initializing component $component: $error');
      rethrow;
    }
  }

  /// Inicializa adaptadores Hive de forma centralizada
  Future<void> _initializeHiveAdapters() async {
    // Esta é uma operação idempotente - os repositories individuais
    // já verificam se o adaptador está registrado antes de registrar
    // Aqui apenas garantimos que todos foram chamados
    
    // Os adaptadores são registrados nos métodos initialize() dos repositories
    // Este método existe apenas para completude do dependency graph
  }

  /// Inicializa o service de assinaturas
  Future<void> _initializeGasometerService() async {
    if (!Get.isRegistered<GasometerSubscriptionService>()) {
      Get.put<GasometerSubscriptionService>(
        GasometerSubscriptionService(),
        permanent: true,
      );
    }
  }

  /// Registra bindings GetX de forma thread-safe
  Future<void> _initializeGetXBindings() async {
    // Registra repositórios apenas se não estiverem registrados
    _registerIfNotExists<VeiculosRepository>(
      () => VeiculosRepository(),
      fenix: true,
    );

    _registerIfNotExists<AbastecimentosRepository>(
      () => AbastecimentosRepository(),
      fenix: true,
    );

    _registerIfNotExists<DespesasRepository>(
      () => DespesasRepository(),
      fenix: true,
    );

    _registerIfNotExists<OdometroRepository>(
      () => OdometroRepository(),
      fenix: true,
    );

    _registerIfNotExists<ManutencoesRepository>(
      () => ManutencoesRepository(),
      fenix: true,
    );

    // GasometerSubscriptionService já foi registrado anteriormente
    // como permanent, então não precisa ser re-registrado
  }

  /// Helper para registrar dependência apenas se não existir
  void _registerIfNotExists<T>(
    T Function() builder, {
    bool fenix = false,
  }) {
    if (!Get.isRegistered<T>()) {
      Get.lazyPut<T>(builder, fenix: fenix);
    }
  }

  /// Retorna o estado atual da inicialização
  String get initializationState => _initializationState;

  /// Verifica se as dependências estão inicializadas
  bool get isInitialized => _initializationState == _stateInitialized;

  /// Reseta o estado de inicialização (útil para testes)
  @visibleForTesting
  void reset() {
    _initializationState = _stateUninitialized;
    _initializationCompleter = null;
    _initializationError = null;
  }
}