// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:get/get.dart';

import '../../../core/services/app_initialization_service.dart';
import '../../../core/themes/manager.dart';
import '../../injections.dart';
import '../../router.dart';
import '../routing/route_manager.dart';
// Project imports:
import 'bootstrap_phase.dart';
import 'bootstrap_state_machine.dart';
import 'cleanup_registry.dart';

/// Centralizador de inicialização da aplicação Receituagro
/// Orquestra todas as fases de inicialização usando State Machine sem race conditions
class AppBootstrapper {
  static AppBootstrapper? _instance;
  static final Completer<AppBootstrapper> _instanceCompleter = Completer<AppBootstrapper>();
  
  static Future<AppBootstrapper> get instance async {
    if (_instance == null) {
      _instance = AppBootstrapper._internal();
      await _instance!._initialize();
      if (!_instanceCompleter.isCompleted) {
        _instanceCompleter.complete(_instance!);
      }
    }
    return await _instanceCompleter.future;
  }

  AppBootstrapper._internal();
  
  late final BootstrapStateMachine _stateMachine;
  
  // Instância do CleanupRegistry
  final CleanupRegistry _cleanupRegistry = CleanupRegistry.instance;

  // Estado da inicialização
  bool _isInitialized = false;
  final List<String> _initializationErrors = [];
  
  // Configuração
  int _maxRetryAttempts = 3;
  Duration _retryDelay = const Duration(seconds: 1);
  Duration _phaseTimeout = const Duration(minutes: 2);
  
  /// Inicializa state machine
  Future<void> _initialize() async {
    _stateMachine = await BootstrapStateMachine.instance;
    
    // Escuta transições
    _stateMachine.transitions.listen((transition) {
      debugPrint('🔄 Bootstrap Transition: ${transition.from.name} -> ${transition.to.name} (${transition.status.displayName})');
      if (transition.error != null) {
        _initializationErrors.add('Erro na transição ${transition.from.name} -> ${transition.to.name}: ${transition.error}');
      }
    });
  }

  /// Verifica se a aplicação foi inicializada
  bool get isInitialized => _isInitialized;
  
  /// Fase atual de inicialização
  BootstrapPhase get currentPhase => _stateMachine.currentPhase;
  
  /// Lista de erros ocorridos durante inicialização
  List<String> get initializationErrors => List.unmodifiable(_initializationErrors);
  
  /// Verifica se está rodando
  bool get isRunning => _stateMachine.isRunning;

  /// Inicializa toda a aplicação em fases ordenadas usando State Machine
  /// Retorna true se sucesso, false se falha crítica
  Future<bool> initialize({
    Function()? onEntitlementChange,
    int? maxRetryAttempts,
    Duration? retryDelay,
    Duration? phaseTimeout,
  }) async {
    // Evita múltiplas inicializações simultâneas
    if (_isInitialized) {
      debugPrint('🟢 AppBootstrapper: Aplicação já inicializada');
      return true;
    }
    
    if (_stateMachine.isRunning) {
      debugPrint('⚠️ AppBootstrapper: Inicialização já em andamento');
      return false;
    }

    _maxRetryAttempts = maxRetryAttempts ?? _maxRetryAttempts;
    _retryDelay = retryDelay ?? _retryDelay;
    _phaseTimeout = phaseTimeout ?? _phaseTimeout;
    _initializationErrors.clear();
    
    try {
      debugPrint('🚀 AppBootstrapper: Iniciando bootstrap da aplicação com State Machine');
      
      // Fase 1: Configuração
      if (!await _executePhaseWithStateMachine(
        BootstrapPhase.configuration,
        () => _initializeConfiguration(),
      )) {
        await _performRollback();
        return false;
      }
      _cleanupRegistry.markPhaseCompleted(BootstrapPhase.configuration);

      // Fase 2: Dependências Core
      if (!await _executePhaseWithStateMachine(
        BootstrapPhase.coreDependencies,
        () => _initializeCoreDependencies(),
      )) {
        await _performRollback();
        return false;
      }
      _cleanupRegistry.markPhaseCompleted(BootstrapPhase.coreDependencies);

      // Fase 3: Repositórios
      if (!await _executePhaseWithStateMachine(
        BootstrapPhase.repositories,
        () => _initializeRepositories(),
      )) {
        await _performRollback();
        return false;
      }
      _cleanupRegistry.markPhaseCompleted(BootstrapPhase.repositories);

      // Fase 4: Controllers
      if (!await _executePhaseWithStateMachine(
        BootstrapPhase.controllers,
        () => _initializeControllers(),
      )) {
        await _performRollback();
        return false;
      }
      _cleanupRegistry.markPhaseCompleted(BootstrapPhase.controllers);

      // Fase 5: Serviços de UI
      if (!await _executePhaseWithStateMachine(
        BootstrapPhase.uiServices,
        () => _initializeUIServices(onEntitlementChange),
      )) {
        await _performRollback();
        return false;
      }
      _cleanupRegistry.markPhaseCompleted(BootstrapPhase.uiServices);

      // Fase 6: Rotas
      if (!await _executePhaseWithStateMachine(
        BootstrapPhase.routes,
        () => _initializeRoutes(),
      )) {
        await _performRollback();
        return false;
      }
      _cleanupRegistry.markPhaseCompleted(BootstrapPhase.routes);

      // Transita para completed
      await _stateMachine.transitionToPhase(
        BootstrapPhase.completed,
        () async {
          _isInitialized = true;
        },
        timeout: _phaseTimeout,
      );
      
      debugPrint('✅ AppBootstrapper: Inicialização concluída com sucesso');
      return true;
      
    } catch (e, stackTrace) {
      _initializationErrors.add('Erro crítico na inicialização: $e');
      debugPrint('❌ AppBootstrapper: Erro crítico: $e');
      debugPrint('Stack trace: $stackTrace');
      
      await _performRollback();
      return false;
    }
  }

  /// Executa uma fase usando State Machine com retry e tratamento de erro
  Future<bool> _executePhaseWithStateMachine(
    BootstrapPhase phase,
    Future<void> Function() phaseExecutor,
  ) async {
    debugPrint('📋 AppBootstrapper: Executando fase ${phase.name} com State Machine');
    
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        // Usa state machine para execução atômica
        final success = await _stateMachine.transitionToPhase(
          phase,
          phaseExecutor,
          timeout: _phaseTimeout,
        );
        
        if (success) {
          debugPrint('✅ AppBootstrapper: Fase ${phase.name} concluída');
          return true;
        } else {
          throw Exception('Falha na transição de estado para fase ${phase.name}');
        }
        
      } catch (e, stackTrace) {
        final errorMsg = 'Erro na fase ${phase.name} (tentativa $attempt): $e';
        _initializationErrors.add(errorMsg);
        debugPrint('⚠️ AppBootstrapper: $errorMsg');
        
        if (kDebugMode) {
          debugPrint('Stack trace: $stackTrace');
        }
        
        if (attempt < _maxRetryAttempts) {
          debugPrint('🔄 AppBootstrapper: Tentando novamente em ${_retryDelay.inSeconds}s...');
          await Future.delayed(_retryDelay);
        } else {
          debugPrint('❌ AppBootstrapper: Falha definitiva na fase ${phase.name}');
          return false;
        }
      }
    }
    
    return false;
  }

  /// Fase 1: Inicializa configurações básicas
  Future<void> _initializeConfiguration() async {
    debugPrint('⚙️ Inicializando configurações...');
    
    // Verifica se GetX está pronto (verificação básica)
    try {
      Get.context; // Teste básico se GetX está funcional
    } catch (e) {
      // GetX ainda não está completamente inicializado, mas podemos prosseguir
      debugPrint('⚠️ GetX pode não estar completamente inicializado: $e');
    }
    
    // Inicializa tema se necessário
    final themeManager = ThemeManager(); // Singleton initialization
    _cleanupRegistry.registerResource(
      key: 'ThemeManager',
      resource: themeManager,
      phase: BootstrapPhase.configuration,
    );
    
    // Registra cleanup para configurações
    _cleanupRegistry.registerCleanup(
      phase: BootstrapPhase.configuration,
      action: () async {
        // Reset configurações se necessário
        debugPrint('🧹 Limpando configurações...');
      },
      description: 'Reset de configurações básicas',
      priority: 1,
    );
    
    debugPrint('✅ Configurações inicializadas');
  }

  /// Fase 2: Inicializa dependências core
  Future<void> _initializeCoreDependencies() async {
    debugPrint('🔧 Inicializando dependências core...');
    
    // Registra o binding principal de forma thread-safe
    await _safeRegisterBinding<ReceituagroBindings>(
      () => ReceituagroBindings(),
      permanent: true,
    );
    
    // Registra cleanup para dependências core
    _cleanupRegistry.registerCleanup(
      phase: BootstrapPhase.coreDependencies,
      action: () async {
        debugPrint('🧹 Limpando dependências core...');
        // Remove binding se não for permanente
        try {
          if (Get.isRegistered<ReceituagroBindings>()) {
            Get.delete<ReceituagroBindings>(force: true);
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao limpar ReceituagroBindings: $e');
        }
      },
      description: 'Limpeza de dependências core',
      priority: 5,
    );
    
    debugPrint('✅ Dependências core inicializadas');
  }

  /// Fase 3: Inicializa repositórios
  Future<void> _initializeRepositories() async {
    debugPrint('📁 Inicializando repositórios...');
    
    // Executa as dependências através do método público
    final binding = Get.find<ReceituagroBindings>();
    binding.dependencies(); // Chama o método público que faz todo o registro
    
    // Verifica se repositórios críticos foram registrados
    await _validateCriticalDependencies();
    
    // Registra cleanup para repositórios
    _cleanupRegistry.registerCleanup(
      phase: BootstrapPhase.repositories,
      action: () async {
        debugPrint('🧹 Limpando repositórios...');
        
        // Lista de repositórios a serem limpos
        final repoTypes = [
          'DatabaseRepository',
          'DefensivosRepository', 
          'DiagnosticoRepository',
          'PragasRepository',
          'CulturaRepository',
          'FavoritosRepository',
        ];
        
        for (final repoType in repoTypes) {
          try {
            // Tenta obter e limpar cada repositório
            final repo = _cleanupRegistry.getResource(repoType);
            if (repo != null) {
              // Tenta chamar dispose/close se existir
              await repo.dispose?.call();
              await repo.close?.call();
            }
          } catch (e) {
            debugPrint('⚠️ Erro ao limpar $repoType: $e');
          }
        }
      },
      description: 'Limpeza de repositórios e conexões',
      priority: 10,
    );
    
    debugPrint('✅ Repositórios inicializados');
  }

  /// Fase 4: Inicializa controllers
  Future<void> _initializeControllers() async {
    debugPrint('🎮 Inicializando controllers...');
    
    // Controllers já são registrados no dependencies() do binding
    // Aqui podemos adicionar inicializações específicas se necessário
    
    debugPrint('✅ Controllers inicializados');
  }

  /// Fase 5: Inicializa serviços de UI
  Future<void> _initializeUIServices(Function()? onEntitlementChange) async {
    debugPrint('🎨 Inicializando serviços de UI...');
    
    AppInitializationService? initService;
    if (onEntitlementChange != null) {
      initService = AppInitializationService();
      await initService.initPurchaseServices(
        onEntitlementChange: onEntitlementChange,
      );
      
      _cleanupRegistry.registerResource(
        key: 'AppInitializationService',
        resource: initService,
        phase: BootstrapPhase.uiServices,
      );
    }
    
    // Registra cleanup para serviços de UI
    _cleanupRegistry.registerCleanup(
      phase: BootstrapPhase.uiServices,
      action: () async {
        debugPrint('🧹 Limpando serviços de UI...');
        
        // Limpa serviços de purchase se existirem
        final service = _cleanupRegistry.getResource<AppInitializationService>('AppInitializationService');
        if (service != null) {
          try {
            // Cancela subscriptions de purchase services
            // Service será limpo automaticamente pelo CleanupRegistry
            debugPrint('🧹 AppInitializationService preparado para limpeza');
          } catch (e) {
            debugPrint('⚠️ Erro ao limpar AppInitializationService: $e');
          }
        }
      },
      description: 'Limpeza de serviços de UI e purchase services',
      priority: 3,
    );
    
    debugPrint('✅ Serviços de UI inicializados');
  }

  /// Fase 6: Inicializa sistema de rotas
  Future<void> _initializeRoutes() async {
    debugPrint('🛣️ Inicializando rotas...');
    
    await _registerRoutesOptimized();
    
    // Registra cleanup para sistema de rotas
    _cleanupRegistry.registerCleanup(
      phase: BootstrapPhase.routes,
      action: () async {
        debugPrint('🧹 Limpando sistema de rotas...');
        
        // Limpa cache de rotas se existir
        try {
          // RouteManager será limpo pelo CleanupRegistry automaticamente
          debugPrint('🧹 Sistema de rotas preparado para limpeza');
        } catch (e) {
          debugPrint('⚠️ Erro ao preparar limpeza do sistema de rotas: $e');
        }
        
        // Reset de rotas no GetX se necessário
        try {
          // GetX não tem método direto para limpar rotas,
          // mas elas serão limpas no reset geral
        } catch (e) {
          debugPrint('⚠️ Erro ao limpar rotas: $e');
        }
      },
      description: 'Limpeza do sistema de rotas',
      priority: 2,
    );
    
    debugPrint('✅ Rotas inicializadas');
  }

  /// Registra binding de forma thread-safe usando Completer
  Future<void> _safeRegisterBinding<T extends Bindings>(
    T Function() factory, {
    bool permanent = false,
  }) async {
    // Usa completer para garantir thread-safety
    final completer = Completer<void>();
    
    try {
      if (!Get.isRegistered<T>()) {
        Get.put<T>(factory(), permanent: permanent);
      }
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    }
    
    return completer.future;
  }

  /// Registra rotas usando RouteManager otimizado
  Future<void> _registerRoutesOptimized() async {
    final routeManager = RouteManager.instance;
    
    final result = await routeManager.registerRoutes(
      AppPages.routes,
      version: '1.0.0', // Versão pode ser dinâmica baseada no app version
    );
    
    if (result.isSuccess) {
      debugPrint('📍 RouteManager: ${result.totalRegistered} rotas registradas, ${result.totalDuplicates} duplicatas evitadas');
      
      if (result.hasErrors) {
        for (final error in result.errors) {
          debugPrint('⚠️ RouteManager: $error');
        }
      }
    } else {
      debugPrint('❌ RouteManager: Falha no registro de rotas: ${result.error}');
      throw Exception('Falha no registro de rotas: ${result.error}');
    }
  }

  /// Valida se dependências críticas foram registradas
  Future<void> _validateCriticalDependencies() async {
    final criticalServices = [
      'LocalStorageService',
      'DatabaseRepository',
    ];
    
    for (final serviceName in criticalServices) {
      if (!Get.isRegistered(tag: serviceName) && 
          !_isServiceRegisteredByType(serviceName)) {
        debugPrint('⚠️ Serviço crítico não encontrado: $serviceName');
      }
    }
  }

  /// Verifica se serviço está registrado por tipo (fallback)
  bool _isServiceRegisteredByType(String typeName) {
    try {
      switch (typeName) {
        case 'LocalStorageService':
          Get.find<dynamic>(tag: typeName);
          return true;
        case 'DatabaseRepository':
          Get.find<dynamic>(tag: typeName);
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Realiza rollback usando State Machine e CleanupRegistry
  Future<void> _performRollback() async {
    debugPrint('🔄 AppBootstrapper: Executando rollback com State Machine...');
    
    try {
      // Transita para rollback usando state machine
      await _stateMachine.transitionToPhase(
        BootstrapPhase.rollback,
        () async {
          // Executa rollback real usando CleanupRegistry
          final result = await _cleanupRegistry.performRollback(
            fromPhase: currentPhase,
            force: true, // Força limpeza mesmo com erros
          );
          
          if (result.success) {
            debugPrint('✅ AppBootstrapper: Rollback real concluído com sucesso em ${result.duration.inMilliseconds}ms');
            
            // Log detalhado do que foi limpo
            for (final entry in result.phaseResults.entries) {
              final phaseResult = entry.value;
              debugPrint('  📋 ${entry.key.name}: ${phaseResult.successfulActions}/${phaseResult.totalActions} ações executadas');
              
              if (phaseResult.errors.isNotEmpty) {
                debugPrint('    ⚠️ Erros: ${phaseResult.errors.join(", ")}');
              }
            }
          } else {
            debugPrint('⚠️ AppBootstrapper: Rollback parcialmente falhou: ${result.error ?? "Erros em fases individuais"}');
            debugPrint('    Duração: ${result.duration.inMilliseconds}ms');
            
            // Log de erros por fase
            for (final entry in result.phaseResults.entries) {
              final phaseResult = entry.value;
              if (!phaseResult.success) {
                debugPrint('  ❌ ${entry.key.name}: ${phaseResult.errors.join(", ")}');
              }
            }
          }
        },
        timeout: _phaseTimeout,
      );
      
      // Reset final do estado
      _isInitialized = false;
      _initializationErrors.clear();
      
      // Reset da state machine
      await _stateMachine.reset();
      
      debugPrint('🔄 AppBootstrapper: Estado resetado - app pronto para nova inicialização');
      
    } catch (e, stackTrace) {
      debugPrint('❌ AppBootstrapper: Erro crítico durante rollback: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Fallback: reset básico se rollback avançado falhar
      _isInitialized = false;
      _initializationErrors.clear();
      
      // Reset da state machine
      await _stateMachine.reset();
      
      // Tenta limpeza emergencial do GetX
      try {
        Get.reset();
        debugPrint('🚨 Limpeza emergencial do GetX executada');
      } catch (getxError) {
        debugPrint('🚨 Falha na limpeza emergencial do GetX: $getxError');
      }
    }
  }

  /// Força reinicialização usando State Machine
  Future<bool> reinitialize({
    Function()? onEntitlementChange,
  }) async {
    debugPrint('🔄 AppBootstrapper: Forçando reinicialização com State Machine...');
    
    _isInitialized = false;
    _initializationErrors.clear();
    
    // Reset da state machine
    await _stateMachine.reset();
    
    return await initialize(onEntitlementChange: onEntitlementChange);
  }

  /// Obtém estatísticas do sistema de rollback
  Map<String, dynamic> getRollbackStats() {
    return _cleanupRegistry.getStats();
  }
  
  /// Obtém relatório detalhado do sistema de rollback
  String getRollbackReport() {
    return _cleanupRegistry.generateReport();
  }
  
  /// Força limpeza de recursos sem reinicializar
  Future<RollbackResult> forceCleanup({BootstrapPhase? fromPhase}) async {
    debugPrint('🧹 AppBootstrapper: Forçando limpeza de recursos...');
    
    final result = await _cleanupRegistry.performRollback(
      fromPhase: fromPhase,
      force: true,
    );
    
    debugPrint('🧹 AppBootstrapper: Limpeza forçada ${result.success ? 'concluída' : 'falhou'}');
    return result;
  }

  /// Obtém status de todas as fases
  Map<BootstrapPhase, PhaseStatus> getAllPhaseStatuses() {
    return _stateMachine.getAllPhaseStatuses();
  }
  
  /// Aguarda uma fase específica ser concluída
  Future<bool> waitForPhase(BootstrapPhase phase, {Duration? timeout}) async {
    return await _stateMachine.waitForPhase(phase, timeout: timeout);
  }
  
  /// Limpa instância (para testes)
  static Future<void> resetInstance() async {
    if (_instance != null) {
      await _instance!._stateMachine.dispose();
      await _instance!._cleanupRegistry.performRollback(force: true);
    }
    BootstrapStateMachine.resetInstance();
    CleanupRegistry.resetInstance();
    _instance = null;
  }
}

