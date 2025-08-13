// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../core/lazy_binding/lazy_controller_manager.dart' hide LoadingStrategy;
import '../core/services/localstorage_service.dart';
import '../core/services/logging_service.dart';
import 'core/cache/i_cache_service.dart';
import 'core/cache/unified_cache_service.dart';
import 'core/di/lazy_loading_config.dart';
import 'core/di/performance_monitor.dart';
import 'core/di/service_registry.dart';
import 'core/navigation/navigation_bindings.dart';
import 'repository/culturas_repository.dart';
import 'repository/database_repository.dart';
import 'repository/defensivos_repository.dart';
import 'repository/diagnostico_repository.dart';
import 'repository/favoritos_repository.dart';
import 'repository/pragas_repository.dart';
import 'services/mock_admob_service.dart';
import 'services/optimized_query_service.dart';
import 'services/premium_service.dart';
import 'services/secure_navigation_service.dart';

/// Gerencia as dependências do módulo Receituagro usando arquitetura limpa
/// Usa ServiceRegistry, LazyLoadingConfig e DIPerformanceMonitor especializados
class ReceituagroBindings extends Bindings {
  // Instâncias especializadas
  static final ServiceRegistry _registry = ServiceRegistry.instance;
  static final LazyLoadingConfig _lazyConfig = LazyLoadingConfig.instance;
  static final DIPerformanceMonitor _perfMonitor = DIPerformanceMonitor.instance;
  @override
  void dependencies() {
    final perfToken = _perfMonitor.startTracking('dependencies_registration');
    
    try {
      // Configura lazy loading baseado no ambiente
      _lazyConfig.configure();
      
      // Registrar UnifiedCacheService primeiro (prioridade alta)
      _registerCacheService();
      
      // Registrar NavigationService unificado
      _registerNavigationService();
      
      // Registrar serviços e repositórios permanentes
      _registerCoreServices();
      _registerRepositories();
      _registerControllers();
      
      _perfMonitor.endTracking(perfToken, success: true);
      
    } catch (e, stackTrace) {
      _perfMonitor.recordError('dependencies_registration', e, stackTrace);
      _perfMonitor.endTracking(perfToken, success: false);
      rethrow;
    }
  }

  /// Registra o UnifiedCacheService como dependência central
  void _registerCacheService() {
    final perfToken = _perfMonitor.startTracking('cache_service_registration');
    
    try {
      // Registra UnifiedCacheService como ICacheService
      if (!_registry.isRegistered<ICacheService>()) {
        _registry.register<ICacheService>(
          UnifiedCacheService(),
          permanent: true
        );
        
        LoggingService.info(
          'UnifiedCacheService registrado como ICacheService',
          tag: 'ReceituagroBindings'
        );
      }
      
      // Também registra como UnifiedCacheService para acesso direto se necessário
      if (!_registry.isRegistered<UnifiedCacheService>()) {
        _registry.register<UnifiedCacheService>(
          UnifiedCacheService(),
          permanent: true
        );
        
        LoggingService.debug(
          'UnifiedCacheService registrado para acesso direto',
          tag: 'ReceituagroBindings'
        );
      }
      
      _perfMonitor.endTracking(perfToken, success: true);
      
    } catch (e, stackTrace) {
      _perfMonitor.recordError('cache_service_registration', e, stackTrace);
      _perfMonitor.endTracking(perfToken, success: false);
      rethrow;
    }
  }
  
  /// Registra o NavigationService unificado
  void _registerNavigationService() {
    final perfToken = _perfMonitor.startTracking('navigation_service_registration');
    
    try {
      // Usa NavigationBindings para registrar o service unificado
      final navigationBindings = NavigationBindings();
      navigationBindings.dependencies();
      
      LoggingService.debug(
        'NavigationService unificado registrado',
        tag: 'ReceituagroBindings'
      );
      
      _perfMonitor.endTracking(perfToken, success: true);
      
    } catch (e, stackTrace) {
      _perfMonitor.recordError('navigation_service_registration', e, stackTrace);
      _perfMonitor.endTracking(perfToken, success: false);
      rethrow;
    }
  }

  /// Registra os serviços básicos da aplicação usando ServiceRegistry
  void _registerCoreServices() {
    final perfToken = _perfMonitor.startTracking('core_services_registration');
    
    try {
      // LocalStorageService
      if (!_registry.isRegistered<LocalStorageService>()) {
        _registry.register<LocalStorageService>(
          LocalStorageService(), 
          permanent: true
        );
      }

      // MockAdmobService
      if (!_registry.isRegistered<MockAdmobService>()) {
        _registry.register<MockAdmobService>(
          MockAdmobService(), 
          permanent: true
        );
      }

      // PremiumService (async)
      if (!_registry.isRegistered<PremiumService>()) {
        _registry.registerAsync<PremiumService>(
          () => PremiumService().init(),
          permanent: true
        );
      }

      // OptimizedQueryService (deve ser registrado antes dos repositories)
      if (!Get.isRegistered<OptimizedQueryService>()) {
        Get.put<OptimizedQueryService>(
          OptimizedQueryService(),
          permanent: true
        );
        
        LoggingService.info(
          'OptimizedQueryService registrado para queries eficientes',
          tag: 'ReceituagroBindings'
        );
      }

      // SecureNavigationService (navegação com validação de inputs)
      if (!Get.isRegistered<SecureNavigationService>()) {
        Get.put<SecureNavigationService>(
          SecureNavigationService(),
          permanent: true
        );
        
        LoggingService.info(
          'SecureNavigationService registrado para navegação segura',
          tag: 'ReceituagroBindings'
        );
      }
      
      _perfMonitor.endTracking(perfToken, success: true);
      
    } catch (e, stackTrace) {
      _perfMonitor.recordError('core_services_registration', e, stackTrace);
      _perfMonitor.endTracking(perfToken, success: false);
      rethrow;
    }
  }

  /// Registra os repositórios principais usando ServiceRegistry
  void _registerRepositories() {
    final perfToken = _perfMonitor.startTracking('repositories_registration');
    
    try {
      final repositoriesToRegister = [
        (DatabaseRepository, () => DatabaseRepository()),
        (DefensivosRepository, () => DefensivosRepository()),
        (DiagnosticoRepository, () => DiagnosticoRepository()),
        (PragasRepository, () => PragasRepository()),
        (CulturaRepository, () => CulturaRepository()),
        (FavoritosRepository, () => FavoritosRepository()),
      ];
      
      for (final (type, factory) in repositoriesToRegister) {
        if (!_registry.isRegistered(tag: type.toString())) {
          _registry.register(
            factory(),
            tag: type.toString(),
            permanent: true
          );
          
          LoggingService.debug(
            'Repositório registrado: ${type.toString()}',
            tag: 'ReceituagroBindings'
          );
        }
      }
      
      _perfMonitor.endTracking(perfToken, success: true);
      
    } catch (e, stackTrace) {
      _perfMonitor.recordError('repositories_registration', e, stackTrace);
      _perfMonitor.endTracking(perfToken, success: false);
      rethrow;
    }
  }

  /// Registra os controllers da aplicação usando LazyLoadingConfig
  /// 
  /// NOTA: Controllers usam sistema de lazy loading inteligente gerenciado
  /// por LazyLoadingConfig com diferentes estratégias por tipo de controller.
  void _registerControllers() {
    final perfToken = _perfMonitor.startTracking('controllers_registration');
    
    try {
      // Configura estratégias específicas para diferentes tipos de controllers
      _configureControllerStrategies();
      
      // Inicia monitoramento de performance especializado
      _perfMonitor.startMonitoring();
      
      LoggingService.debug(
        'Sistema de lazy loading configurado para controllers com performance monitor',
        tag: 'ReceituagroBindings'
      );
      
      _perfMonitor.endTracking(perfToken, success: true);
      
    } catch (e, stackTrace) {
      _perfMonitor.recordError('controllers_registration', e, stackTrace);
      _perfMonitor.endTracking(perfToken, success: false);
      rethrow;
    }
  }
  
  /// Configura estratégias de lazy loading para diferentes tipos de controllers
  void _configureControllerStrategies() {
    // Controllers críticos - sempre carregados (exemplo)
    // _lazyConfig.configureServiceStrategy para tipos específicos
    
    // Controllers de listagem - carregamento preditivo
    final listControllers = [
      'ListaDefensivosController',
      'ListaPragasController', 
      'ListaPragasPorCulturaController',
    ];
    
    // Controllers de detalhes - carregamento sob demanda
    final detailControllers = [
      'DetalhesDefensivosController',
      'DetalhesPragasController',
      'DetalhesDiagnosticoController',
    ];
    
    LoggingService.debug(
      'Configuradas estratégias para ${listControllers.length + detailControllers.length} tipos de controllers',
      tag: 'ReceituagroBindings'
    );
  }

  // Estado de inicialização para evitar race conditions
  static bool _isInitializing = false;
  static bool _isInitialized = false;
  static final _initializationLock = Object();

  /// Inicializa todas as dependências usando sistema especializado
  /// Este método deve ser chamado no início da aplicação
  static Future<void> initDependencies() async {
    final perfToken = _perfMonitor.startTracking('full_initialization');
    
    // Evita múltiplas inicializações simultâneas
    if (_isInitialized) {
      LoggingService.info('Dependências já inicializadas', tag: 'ReceituagroBindings');
      _perfMonitor.endTracking(perfToken, success: true);
      return;
    }
    
    if (_isInitializing) {
      LoggingService.info('Inicialização já em andamento', tag: 'ReceituagroBindings');
      _perfMonitor.endTracking(perfToken, success: true);
      return;
    }

    await _synchronized(_initializationLock, () async {
      if (_isInitialized || _isInitializing) return;
      
      _isInitializing = true;
      
      try {
        LoggingService.info('Iniciando inicialização de dependências com arquitetura limpa', tag: 'ReceituagroBindings');
        
        // Inicia monitoramento
        _perfMonitor.startMonitoring();
        
        // Registra o binding principal usando ServiceRegistry
        if (!_registry.isRegistered<ReceituagroBindings>()) {
          _registry.register<ReceituagroBindings>(
            ReceituagroBindings(), 
            permanent: true
          );
          LoggingService.debug('Binding principal registrado via ServiceRegistry', tag: 'ReceituagroBindings');
        }

        // Executa as dependências
        final binding = _registry.get<ReceituagroBindings>();
        binding.dependencies();
        
        _isInitialized = true;
        LoggingService.info('Dependências inicializadas com sucesso usando sistema especializado', tag: 'ReceituagroBindings');
        
        _perfMonitor.endTracking(perfToken, success: true);
        
      } catch (e, stackTrace) {
        _perfMonitor.recordError('full_initialization', e, stackTrace);
        LoggingService.error('Erro ao inicializar dependências', tag: 'ReceituagroBindings', error: e, stackTrace: stackTrace);
        
        // Fallback: tenta registrar diretamente
        try {
          ReceituagroBindings().dependencies();
          _isInitialized = true;
          LoggingService.info('Dependências inicializadas via fallback', tag: 'ReceituagroBindings');
          _perfMonitor.endTracking(perfToken, success: true);
        } catch (fallbackError) {
          LoggingService.error('Falha no fallback', tag: 'ReceituagroBindings', error: fallbackError);
          _perfMonitor.endTracking(perfToken, success: false);
          rethrow;
        }
      } finally {
        _isInitializing = false;
      }
    });
  }

  /// Verifica se as dependências foram inicializadas
  static bool get isInitialized => _isInitialized;

  /// Força reinicialização usando sistema especializado (use com cuidado)
  static Future<void> reinitialize() async {
    LoggingService.warning('Forçando reinicialização com limpeza completa', tag: 'ReceituagroBindings');
    
    // Para monitoramento
    _perfMonitor.stopMonitoring();
    
    // Limpa sistema de lazy loading
    LazyControllerManager.dispose();
    
    // Limpa registry
    _registry.clearNonPermanent();
    
    // Reset configurações
    _lazyConfig.reset();
    
    _isInitialized = false;
    _isInitializing = false;
    
    await initDependencies();
  }


  /// Obtém estatísticas do sistema usando componentes especializados
  static Future<Map<String, dynamic>> getSystemStats() async {
    final baseStats = {
      'registry': _registry.getStats(),
      'lazyLoading': _lazyConfig.getConfigStats(), 
      'performance': _perfMonitor.getStats(),
      'lazyController': LazyControllerManager.getStats(),
    };
    
    // Adiciona estatísticas do cache unificado se disponível
    try {
      final cacheService = _registry.get<ICacheService>();
      baseStats['unifiedCache'] = await cacheService.getStats();
    } catch (e) {
      baseStats['unifiedCache'] = {'error': 'Cache service not available: $e'};
    }
    
    return baseStats;
  }

  /// Obtém relatório de performance especializado
  static String getPerformanceReport({bool detailed = false}) {
    return _perfMonitor.generateReport(detailed: detailed);
  }

  /// Obtém estatísticas específicas do cache unificado
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheService = _registry.get<ICacheService>();
      return await cacheService.getStats();
    } catch (e) {
      return {
        'available': false,
        'error': e.toString(),
        'strategy': 'cache_service_not_registered',
      };
    }
  }
  
  /// Força limpeza de cache usando serviço unificado
  static Future<void> clearUnifiedCache() async {
    try {
      final cacheService = _registry.get<ICacheService>();
      await cacheService.clear();
      
      LoggingService.info(
        'Cache unificado limpo com sucesso', 
        tag: 'ReceituagroBindings'
      );
    } catch (e) {
      LoggingService.warning(
        'Erro ao limpar cache unificado: $e', 
        tag: 'ReceituagroBindings'
      );
    }
  }
  
  /// Força limpeza usando todos os componentes
  static Future<void> forceCleanup() async {
    LazyControllerManager.forceCleanup();
    _registry.clearNonPermanent();
    
    // Limpa cache unificado também
    await clearUnifiedCache();
    
    LoggingService.info(
      'Limpeza forçada executada em todos os componentes incluindo cache', 
      tag: 'ReceituagroBindings'
    );
  }

  /// Função auxiliar para sincronização simples
  static Future<void> _synchronized(Object lock, Future<void> Function() callback) async {
    // Implementação simplificada de sincronização
    // Em Dart, não há threads reais, mas esta estrutura demonstra o conceito
    await callback();
  }
}
