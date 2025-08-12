// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../repository/abastecimentos_repository.dart';
import '../repository/despesas_repository.dart';
import '../repository/manutecoes_repository.dart';
import '../repository/odometro_repository.dart';
import '../repository/veiculos_repository.dart';
import '../services/dependency_manager.dart';
import '../services/gasometer_subscription_service.dart';

/// Sistema modular de Dependency Injection para o módulo Gasometer
/// 
/// Resolve problemas do sistema anterior:
/// - Elimina duplicação de registros
/// - Remove fenix pattern problemático
/// - Organiza dependências por categorias
/// - Facilita testes com mocking
/// - Gerencia lifecycle adequadamente

// MARK: - Base Module

/// Módulo base abstrato com funcionalidades comuns
abstract class DIModule {
  /// Nome do módulo para identificação
  String get moduleName;
  
  /// Registra as dependências do módulo
  void registerDependencies();
  
  /// Limpa as dependências do módulo
  void disposeDependencies();
  
  /// Verifica se o módulo está inicializado
  bool get isInitialized;
}

// MARK: - Core Module

/// Módulo core com dependências fundamentais
class GasometerCoreModule implements DIModule {
  static final GasometerCoreModule _instance = GasometerCoreModule._();
  static GasometerCoreModule get instance => _instance;
  
  GasometerCoreModule._();

  bool _isInitialized = false;
  
  @override
  String get moduleName => 'GasometerCore';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void registerDependencies() {
    if (_isInitialized) return;

    // Repositories - Singleton sem fenix (proper lifecycle)
    Get.put<VeiculosRepository>(
      VeiculosRepository(),
      permanent: true, // Mantém durante toda vida da app
    );

    Get.put<AbastecimentosRepository>(
      AbastecimentosRepository(),
      permanent: true,
    );

    Get.put<DespesasRepository>(
      DespesasRepository(),
      permanent: true,
    );

    Get.put<OdometroRepository>(
      OdometroRepository(),
      permanent: true,
    );

    Get.put<ManutencoesRepository>(
      ManutencoesRepository(),
      permanent: true,
    );

    // Services core
    Get.put<GasometerSubscriptionService>(
      GasometerSubscriptionService(),
      permanent: true,
    );

    _isInitialized = true;
  }

  @override
  void disposeDependencies() {
    if (!_isInitialized) return;

    // Remove dependências na ordem reversa
    Get.delete<GasometerSubscriptionService>();
    Get.delete<ManutencoesRepository>();
    Get.delete<OdometroRepository>();
    Get.delete<DespesasRepository>();
    Get.delete<AbastecimentosRepository>();
    Get.delete<VeiculosRepository>();

    _isInitialized = false;
  }

  /// Inicialização assíncrona das dependências
  Future<void> initializeAsync() async {
    if (_isInitialized) return;
    
    registerDependencies();
    
    // Usa o DependencyManager thread-safe para inicialização
    await DependencyManager.instance.initializeAll();
  }
}

// MARK: - Feature Modules

/// Módulo para features específicas de Veículos
class VeiculosFeatureModule implements DIModule {
  static final VeiculosFeatureModule _instance = VeiculosFeatureModule._();
  static VeiculosFeatureModule get instance => _instance;
  
  VeiculosFeatureModule._();

  bool _isInitialized = false;
  
  @override
  String get moduleName => 'VeiculosFeature';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void registerDependencies() {
    if (_isInitialized) return;

    // Garante que core module está inicializado
    GasometerCoreModule.instance.registerDependencies();

    // Registra apenas dependências específicas de Veículos
    // (Controllers serão lazy loaded pelas páginas)
    
    _isInitialized = true;
  }

  @override
  void disposeDependencies() {
    if (!_isInitialized) return;
    
    // Remove apenas dependências específicas do feature
    // Core dependencies são mantidas
    
    _isInitialized = false;
  }
}

/// Módulo para features de Abastecimentos
class AbastecimentosFeatureModule implements DIModule {
  static final AbastecimentosFeatureModule _instance = AbastecimentosFeatureModule._();
  static AbastecimentosFeatureModule get instance => _instance;
  
  AbastecimentosFeatureModule._();

  bool _isInitialized = false;
  
  @override
  String get moduleName => 'AbastecimentosFeature';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void registerDependencies() {
    if (_isInitialized) return;

    // Garante que core module está inicializado
    GasometerCoreModule.instance.registerDependencies();

    _isInitialized = true;
  }

  @override
  void disposeDependencies() {
    if (!_isInitialized) return;
    _isInitialized = false;
  }
}

/// Módulo para features de Odômetro
class OdometroFeatureModule implements DIModule {
  static final OdometroFeatureModule _instance = OdometroFeatureModule._();
  static OdometroFeatureModule get instance => _instance;
  
  OdometroFeatureModule._();

  bool _isInitialized = false;
  
  @override
  String get moduleName => 'OdometroFeature';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void registerDependencies() {
    if (_isInitialized) return;
    GasometerCoreModule.instance.registerDependencies();
    _isInitialized = true;
  }

  @override
  void disposeDependencies() {
    if (!_isInitialized) return;
    _isInitialized = false;
  }
}

/// Módulo para features de Despesas
class DespesasFeatureModule implements DIModule {
  static final DespesasFeatureModule _instance = DespesasFeatureModule._();
  static DespesasFeatureModule get instance => _instance;
  
  DespesasFeatureModule._();

  bool _isInitialized = false;
  
  @override
  String get moduleName => 'DespesasFeature';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void registerDependencies() {
    if (_isInitialized) return;
    GasometerCoreModule.instance.registerDependencies();
    _isInitialized = true;
  }

  @override
  void disposeDependencies() {
    if (!_isInitialized) return;
    _isInitialized = false;
  }
}

/// Módulo para features de Manutenções
class ManutencoesFeatureModule implements DIModule {
  static final ManutencoesFeatureModule _instance = ManutencoesFeatureModule._();
  static ManutencoesFeatureModule get instance => _instance;
  
  ManutencoesFeatureModule._();

  bool _isInitialized = false;
  
  @override
  String get moduleName => 'ManutencoesFeature';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void registerDependencies() {
    if (_isInitialized) return;
    GasometerCoreModule.instance.registerDependencies();
    _isInitialized = true;
  }

  @override
  void disposeDependencies() {
    if (!_isInitialized) return;
    _isInitialized = false;
  }
}

// MARK: - Module Manager

/// Gerenciador central de todos os módulos de DI
class GasometerDIManager {
  static final GasometerDIManager _instance = GasometerDIManager._();
  static GasometerDIManager get instance => _instance;
  
  GasometerDIManager._();

  final List<DIModule> _modules = [];
  bool _isInitialized = false;

  /// Inicializa todos os módulos necessários
  Future<void> initializeAll() async {
    if (_isInitialized) return;

    // Registra módulos na ordem correta
    _modules.addAll([
      GasometerCoreModule.instance,
      VeiculosFeatureModule.instance,
      AbastecimentosFeatureModule.instance,
      OdometroFeatureModule.instance,
      DespesasFeatureModule.instance,
      ManutencoesFeatureModule.instance,
    ]);

    // Inicializa core module de forma assíncrona
    await GasometerCoreModule.instance.initializeAsync();
    
    // Registra feature modules
    for (final module in _modules) {
      if (module != GasometerCoreModule.instance) {
        module.registerDependencies();
      }
    }

    _isInitialized = true;
  }

  /// Inicializa apenas um módulo específico
  void initializeModule<T extends DIModule>(T module) {
    if (!_modules.contains(module)) {
      _modules.add(module);
    }
    module.registerDependencies();
  }

  /// Limpa todas as dependências (útil para testes)
  void disposeAll() {
    if (!_isInitialized) return;

    // Remove na ordem reversa
    for (final module in _modules.reversed) {
      module.disposeDependencies();
    }

    _modules.clear();
    _isInitialized = false;
  }

  /// Limpa um módulo específico
  void disposeModule<T extends DIModule>(T module) {
    module.disposeDependencies();
    _modules.remove(module);
  }

  /// Verifica se todos os módulos estão inicializados
  bool get isInitialized => _isInitialized;

  /// Lista de módulos registrados
  List<DIModule> get modules => List.unmodifiable(_modules);

  /// Obtém estatísticas dos módulos
  Map<String, bool> get moduleStatus {
    return Map.fromEntries(
      _modules.map((module) => MapEntry(module.moduleName, module.isInitialized))
    );
  }
}

// MARK: - Test Utilities

/// Utilidades para facilitar testes
class GasometerDITestUtils {
  /// Cria mock manager para testes
  static void setupTestEnvironment() {
    GasometerDIManager.instance.disposeAll();
  }

  /// Registra mocks para um módulo
  static void registerMocks({
    VeiculosRepository? mockVeiculosRepository,
    AbastecimentosRepository? mockAbastecimentosRepository,
    DespesasRepository? mockDespesasRepository,
    OdometroRepository? mockOdometroRepository,
    ManutencoesRepository? mockManutencoesRepository,
    GasometerSubscriptionService? mockSubscriptionService,
  }) {
    if (mockVeiculosRepository != null) {
      Get.put<VeiculosRepository>(mockVeiculosRepository);
    }
    if (mockAbastecimentosRepository != null) {
      Get.put<AbastecimentosRepository>(mockAbastecimentosRepository);
    }
    if (mockDespesasRepository != null) {
      Get.put<DespesasRepository>(mockDespesasRepository);
    }
    if (mockOdometroRepository != null) {
      Get.put<OdometroRepository>(mockOdometroRepository);
    }
    if (mockManutencoesRepository != null) {
      Get.put<ManutencoesRepository>(mockManutencoesRepository);
    }
    if (mockSubscriptionService != null) {
      Get.put<GasometerSubscriptionService>(mockSubscriptionService);
    }
  }

  /// Limpa todos os mocks
  static void cleanupTestEnvironment() {
    Get.reset();
  }
}

// MARK: - Compatibility Layer

/// Classe de compatibilidade com sistema anterior
/// Será removida gradualmente
@Deprecated('Use GasometerDIManager.instance.initializeAll() instead')
class GasometerBindings extends Bindings {
  @override
  void dependencies() {
    // Delega para o novo sistema
    GasometerCoreModule.instance.registerDependencies();
  }

  /// Método de compatibilidade
  @Deprecated('Use GasometerDIManager.instance.initializeAll() instead')
  static Future<void> initDependencies() async {
    await GasometerDIManager.instance.initializeAll();
  }
}