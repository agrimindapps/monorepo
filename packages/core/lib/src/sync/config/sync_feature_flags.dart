/// Feature flags para migração gradual do UnifiedSyncManager
/// Permite ativar/desativar a nova arquitetura SOLID por partes
class SyncFeatureFlags {
  static final SyncFeatureFlags _instance = SyncFeatureFlags._internal();
  static SyncFeatureFlags get instance => _instance;
  
  SyncFeatureFlags._internal();
  
  // Feature flags para componentes individuais (mutáveis para migração)
  bool _useNewCacheManager = false;
  bool _useNewNetworkMonitor = false; 
  bool _useNewSyncOrchestrator = false;
  bool _useNewSyncServiceFactory = false;
  
  // Feature flags por app para rollout gradual (mutáveis para migração)
  bool _enableForGasometer = false;
  bool _enableForPlantis = false;
  bool _enableForTaskolist = false;
  bool _enableForReceituagro = false;
  bool _enableForPetiveti = false;
  bool _enableForAgrihurbi = false;
  
  // Getters para feature flags de componentes
  bool get useNewCacheManager => _useNewCacheManager;
  bool get useNewNetworkMonitor => _useNewNetworkMonitor;
  bool get useNewSyncOrchestrator => _useNewSyncOrchestrator;
  bool get useNewSyncServiceFactory => _useNewSyncServiceFactory;
  
  // Getters para feature flags por app
  bool get enableForGasometer => _enableForGasometer;
  bool get enableForPlantis => _enableForPlantis;
  bool get enableForTaskolist => _enableForTaskolist;
  bool get enableForReceituagro => _enableForReceituagro;
  bool get enableForPetiveti => _enableForPetiveti;
  bool get enableForAgrihurbi => _enableForAgrihurbi;
  
  // Métodos para controlar feature flags durante migração
  
  /// Ativa nova arquitetura globalmente
  void enableNewSyncOrchestrator() {
    _useNewSyncOrchestrator = true;
  }
  
  /// Desativa nova arquitetura globalmente
  void disableNewSyncOrchestrator() {
    _useNewSyncOrchestrator = false;
  }
  
  /// Ativa feature flag para um app específico
  void enableForApp(String appId) {
    switch (appId.toLowerCase()) {
      case 'gasometer':
      case 'app-gasometer':
        _enableForGasometer = true;
        break;
      case 'plantis':
      case 'app-plantis':
        _enableForPlantis = true;
        break;
      case 'taskolist':
      case 'app_taskolist':
        _enableForTaskolist = true;
        break;
      case 'receituagro':
      case 'app-receituagro':
        _enableForReceituagro = true;
        break;
      case 'petiveti':
      case 'app-petiveti':
        _enableForPetiveti = true;
        break;
      case 'agrihurbi':
      case 'app_agrihurbi':
        _enableForAgrihurbi = true;
        break;
    }
  }
  
  /// Desativa feature flag para um app específico
  void disableForApp(String appId) {
    switch (appId.toLowerCase()) {
      case 'gasometer':
      case 'app-gasometer':
        _enableForGasometer = false;
        break;
      case 'plantis':
      case 'app-plantis':
        _enableForPlantis = false;
        break;
      case 'taskolist':
      case 'app_taskolist':
        _enableForTaskolist = false;
        break;
      case 'receituagro':
      case 'app-receituagro':
        _enableForReceituagro = false;
        break;
      case 'petiveti':
      case 'app-petiveti':
        _enableForPetiveti = false;
        break;
      case 'agrihurbi':
      case 'app_agrihurbi':
        _enableForAgrihurbi = false;
        break;
    }
  }
  
  /// Ativa todos os componentes da nova arquitetura
  void enableAllComponents() {
    _useNewCacheManager = true;
    _useNewNetworkMonitor = true;
    _useNewSyncOrchestrator = true;
    _useNewSyncServiceFactory = true;
  }
  
  /// Desativa todos os componentes (volta para legacy)
  void disableAllComponents() {
    _useNewCacheManager = false;
    _useNewNetworkMonitor = false;
    _useNewSyncOrchestrator = false;
    _useNewSyncServiceFactory = false;
  }
  
  /// Ativa feature flags para todos os apps
  void enableAllApps() {
    _enableForGasometer = true;
    _enableForPlantis = true;
    _enableForTaskolist = true;
    _enableForReceituagro = true;
    _enableForPetiveti = true;
    _enableForAgrihurbi = true;
  }
  
  /// Desativa feature flags para todos os apps
  void disableAllApps() {
    _enableForGasometer = false;
    _enableForPlantis = false;
    _enableForTaskolist = false;
    _enableForReceituagro = false;
    _enableForPetiveti = false;
    _enableForAgrihurbi = false;
  }
  
  /// Verifica se a nova arquitetura está habilitada para um app específico
  bool isEnabledForApp(String appId) {
    switch (appId.toLowerCase()) {
      case 'gasometer':
      case 'app-gasometer':
        return enableForGasometer;
      case 'plantis':
      case 'app-plantis':
        return enableForPlantis;
      case 'taskolist':
      case 'app_taskolist':
        return enableForTaskolist;
      case 'receituagro':
      case 'app-receituagro':
        return enableForReceituagro;
      case 'petiveti':
      case 'app-petiveti':
        return enableForPetiveti;
      case 'agrihurbi':
      case 'app_agrihurbi':
        return enableForAgrihurbi;
      default:
        return false;
    }
  }
  
  /// Verifica se todos os componentes estão habilitados
  bool get isFullyEnabled => 
      useNewCacheManager && 
      useNewNetworkMonitor && 
      useNewSyncOrchestrator && 
      useNewSyncServiceFactory;
  
  /// Verifica se nenhum componente está habilitado (modo legacy)
  bool get isLegacyMode => 
      !useNewCacheManager && 
      !useNewNetworkMonitor && 
      !useNewSyncOrchestrator && 
      !useNewSyncServiceFactory;
  
  /// Obtém lista de componentes habilitados
  List<String> get enabledComponents {
    final enabled = <String>[];
    
    if (useNewCacheManager) enabled.add('CacheManager');
    if (useNewNetworkMonitor) enabled.add('NetworkMonitor');
    if (useNewSyncOrchestrator) enabled.add('SyncOrchestrator');
    if (useNewSyncServiceFactory) enabled.add('SyncServiceFactory');
    
    return enabled;
  }
  
  /// Obtém lista de apps habilitados
  List<String> get enabledApps {
    final enabled = <String>[];
    
    if (enableForGasometer) enabled.add('gasometer');
    if (enableForPlantis) enabled.add('plantis');
    if (enableForTaskolist) enabled.add('taskolist');
    if (enableForReceituagro) enabled.add('receituagro');
    if (enableForPetiveti) enabled.add('petiveti');
    if (enableForAgrihurbi) enabled.add('agrihurbi');
    
    return enabled;
  }
  
  /// Informações de debug sobre o estado das feature flags
  Map<String, dynamic> getDebugInfo() {
    return {
      'components': {
        'cache_manager': useNewCacheManager,
        'network_monitor': useNewNetworkMonitor,
        'sync_orchestrator': useNewSyncOrchestrator,
        'sync_service_factory': useNewSyncServiceFactory,
      },
      'apps': {
        'gasometer': enableForGasometer,
        'plantis': enableForPlantis,
        'taskolist': enableForTaskolist,
        'receituagro': enableForReceituagro,
        'petiveti': enableForPetiveti,
        'agrihurbi': enableForAgrihurbi,
      },
      'status': {
        'fully_enabled': isFullyEnabled,
        'legacy_mode': isLegacyMode,
        'enabled_components': enabledComponents,
        'enabled_apps': enabledApps,
      },
    };
  }
  
  /// Estratégia de rollout recomendada
  static const Map<String, List<String>> rolloutStrategy = {
    'sprint_1': ['CacheManager'], // Componente mais isolado
    'sprint_2': ['NetworkMonitor'], // Sem dependências complexas
    'sprint_3': ['SyncServiceFactory'], // Factory pattern
    'sprint_4': ['SyncOrchestrator'], // Orchestrador principal
    'sprint_5': ['gasometer'], // App piloto
    'sprint_6': ['plantis', 'taskolist'], // Apps secundários
    'sprint_7': ['receituagro', 'petiveti', 'agrihurbi'], // Apps restantes
  };
}