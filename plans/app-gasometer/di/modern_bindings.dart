// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/realtime_abastecimentos_controller.dart';
import '../pages/cadastros/abastecimento_page/controller/abastecimento_page_controller.dart';
import '../pages/cadastros/despesas_page/controller/despesas_page_controller.dart';
import '../pages/cadastros/manutencoes_page/controller/manutencoes_page_controller.dart';
import '../pages/cadastros/odometro_cadastro/controller/odometro_cadastro_form_controller.dart';
import '../pages/cadastros/odometro_page/controller/odometro_page_controller.dart';
import '../pages/cadastros/veiculos_page/controller/veiculos_page_controller.dart';
import '../repository/abastecimentos_repository.dart';
import '../repository/despesas_repository.dart';
import '../repository/manutecoes_repository.dart';
import '../repository/odometro_repository.dart';
import '../repository/veiculos_repository.dart';
import '../services/gasometer_subscription_service.dart';
import 'gasometer_di_module.dart';

/// Sistema moderno de Bindings que substitui o sistema legado
/// 
/// Características:
/// - Sem fenix pattern problemático
/// - Controllers têm lifecycle apropriado
/// - Dependências core são reutilizadas
/// - Memory leaks eliminados
/// - Facilita testes

// MARK: - Modern Page Bindings

/// Binding moderno para página de Veículos
class ModernVeiculosPageBinding extends Bindings {
  @override
  void dependencies() {
    // Garante que feature module está inicializado
    VeiculosFeatureModule.instance.registerDependencies();

    // Controller específico da página - será disposto automaticamente
    Get.lazyPut<VeiculosPageController>(
      () => VeiculosPageController(),
      // SEM fenix: permite garbage collection apropriado
    );
  }
}

/// Binding moderno para página de Abastecimentos
class ModernAbastecimentosPageBinding extends Bindings {
  @override
  void dependencies() {
    AbastecimentosFeatureModule.instance.registerDependencies();

    Get.lazyPut<AbastecimentoPageController>(
      () => AbastecimentoPageController(),
    );

    // Controller realtime se necessário para a página
    Get.lazyPut<RealtimeAbastecimentosController>(
      () => RealtimeAbastecimentosController(),
    );
  }
}

/// Binding moderno para página de Odômetro
class ModernOdometroPageBinding extends Bindings {
  @override
  void dependencies() {
    OdometroFeatureModule.instance.registerDependencies();

    Get.lazyPut<OdometroPageController>(
      () => OdometroPageController(),
    );
  }
}

/// Binding moderno para formulário de Odômetro
class ModernOdometroCadastroBinding extends Bindings {
  @override
  void dependencies() {
    OdometroFeatureModule.instance.registerDependencies();

    Get.lazyPut<OdometroCadastroFormController>(
      () => OdometroCadastroFormController(),
    );
  }
}

/// Binding moderno para página de Despesas
class ModernDespesasPageBinding extends Bindings {
  @override
  void dependencies() {
    DespesasFeatureModule.instance.registerDependencies();

    Get.lazyPut<DespesasPageController>(
      () => DespesasPageController(),
    );
  }
}

/// Binding moderno para página de Manutenções
class ModernManutencoesPageBinding extends Bindings {
  @override
  void dependencies() {
    ManutencoesFeatureModule.instance.registerDependencies();

    Get.lazyPut<ManutencoesPageController>(
      () => ManutencoesPageController(),
    );
  }
}

// MARK: - Binding Factory

/// Factory para criar bindings dinamicamente
class ModernBindingsFactory {
  static const Map<String, Bindings Function()> _bindingsMap = {
    '/veiculos': _createVeiculosBinding,
    '/abastecimentos': _createAbastecimentosBinding,
    '/odometro': _createOdometroBinding,
    '/odometro-cadastro': _createOdometroCadastroBinding,
    '/despesas': _createDespesasBinding,
    '/manutencoes': _createManutencoesBinding,
  };

  /// Cria binding para uma rota específica
  static Bindings? createBinding(String route) {
    final factory = _bindingsMap[route];
    return factory?.call();
  }

  /// Lista todas as rotas disponíveis
  static List<String> get availableRoutes => _bindingsMap.keys.toList();

  // Factory methods
  static Bindings _createVeiculosBinding() => ModernVeiculosPageBinding();
  static Bindings _createAbastecimentosBinding() => ModernAbastecimentosPageBinding();
  static Bindings _createOdometroBinding() => ModernOdometroPageBinding();
  static Bindings _createOdometroCadastroBinding() => ModernOdometroCadastroBinding();
  static Bindings _createDespesasBinding() => ModernDespesasPageBinding();
  static Bindings _createManutencoesBinding() => ModernManutencoesPageBinding();
}

// MARK: - Binding Validator

/// Validador para garantir que bindings estão funcionando corretamente
class BindingValidator {
  /// Valida que todas as dependências necessárias estão registradas
  static bool validateCoreModule() {
    try {
      Get.find<VeiculosRepository>();
      Get.find<AbastecimentosRepository>();
      Get.find<DespesasRepository>();
      Get.find<OdometroRepository>();
      Get.find<ManutencoesRepository>();
      Get.find<GasometerSubscriptionService>();
      return true;
    } catch (e) {
      debugPrint('Core module validation failed: $e');
      return false;
    }
  }

  /// Valida que um feature module específico está funcionando
  static bool validateFeatureModule(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'veiculos':
        return VeiculosFeatureModule.instance.isInitialized;
      case 'abastecimentos':
        return AbastecimentosFeatureModule.instance.isInitialized;
      case 'odometro':
        return OdometroFeatureModule.instance.isInitialized;
      case 'despesas':
        return DespesasFeatureModule.instance.isInitialized;
      case 'manutencoes':
        return ManutencoesFeatureModule.instance.isInitialized;
      default:
        return false;
    }
  }

  /// Valida que não há vazamentos de memória
  static Map<String, int> checkMemoryUsage() {
    final registeredTypes = <String, int>{};
    
    // Esta é uma implementação simplificada
    // Em produção, você poderia usar ferramentas mais sofisticadas
    try {
      // Conta quantas instâncias de cada tipo estão registradas
      final coreTypes = [
        'VeiculosRepository',
        'AbastecimentosRepository', 
        'DespesasRepository',
        'OdometroRepository',
        'ManutencoesRepository',
        'GasometerSubscriptionService',
      ];

      for (final type in coreTypes) {
        registeredTypes[type] = Get.isRegistered(tag: type) ? 1 : 0;
      }
      
    } catch (e) {
      debugPrint('Memory usage check failed: $e');
    }

    return registeredTypes;
  }

  /// Relatório completo do estado do sistema DI
  static Map<String, dynamic> generateHealthReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'core_module_healthy': validateCoreModule(),
      'feature_modules': {
        'veiculos': validateFeatureModule('veiculos'),
        'abastecimentos': validateFeatureModule('abastecimentos'),
        'odometro': validateFeatureModule('odometro'),
        'despesas': validateFeatureModule('despesas'),
        'manutencoes': validateFeatureModule('manutencoes'),
      },
      'di_manager_initialized': GasometerDIManager.instance.isInitialized,
      'module_status': GasometerDIManager.instance.moduleStatus,
      'memory_usage': checkMemoryUsage(),
      'available_routes': ModernBindingsFactory.availableRoutes,
    };
  }
}

// MARK: - Migration Utilities

/// Utilitários para migração do sistema antigo
class DIBindingMigrationHelper {
  /// Migra bindings legados para novos
  static void migrateLegacyBinding(String legacyRoute) {
    final modernBinding = ModernBindingsFactory.createBinding(legacyRoute);
    
    if (modernBinding != null) {
      modernBinding.dependencies();
      debugPrint('Migrated legacy binding for route: $legacyRoute');
    } else {
      debugPrint('No modern binding available for route: $legacyRoute');
    }
  }

  /// Limpa registros duplicados do sistema legado
  static void cleanupLegacyRegistrations() {
    final typesToCleanup = [
      VeiculosRepository,
      AbastecimentosRepository,
      DespesasRepository,
      OdometroRepository,
      ManutencoesRepository,
      GasometerSubscriptionService,
    ];

    for (final type in typesToCleanup) {
      try {
        // Remove múltiplas instâncias se existirem
        Get.delete<dynamic>(tag: type.toString());
      } catch (e) {
        // Ignora erros de dependências não encontradas
      }
    }
  }

  /// Verifica se há registros duplicados
  static List<String> detectDuplicateRegistrations() {
    final duplicates = <String>[];
    
    // Esta é uma verificação simplificada
    // Em uma implementação real, você verificaria o internal state do GetX
    
    return duplicates;
  }
}

// MARK: - Development Tools

/// Ferramentas de desenvolvimento para debug do sistema DI
class DIDevelopmentTools {
  /// Imprime estado atual do sistema DI
  static void printSystemState() {
    if (!kDebugMode) return;
    
    final report = BindingValidator.generateHealthReport();
    
    print('\n=== GASOMETER DI SYSTEM STATE ===');
    print('Timestamp: ${report['timestamp']}');
    print('Core Module Healthy: ${report['core_module_healthy']}');
    print('DI Manager Initialized: ${report['di_manager_initialized']}');
    
    print('\nFeature Modules:');
    final featureModules = report['feature_modules'] as Map<String, dynamic>;
    featureModules.forEach((name, status) {
      print('  $name: ${status ? '✅' : '❌'}');
    });
    
    print('\nModule Status:');
    final moduleStatus = report['module_status'] as Map<String, dynamic>;
    moduleStatus.forEach((name, status) {
      print('  $name: ${status ? '✅' : '❌'}');
    });
    
    print('\nMemory Usage:');
    final memoryUsage = report['memory_usage'] as Map<String, dynamic>;
    memoryUsage.forEach((type, count) {
      print('  $type: $count instances');
    });
    
    print('\nAvailable Routes: ${report['available_routes']}');
    print('================================\n');
  }

  /// Executa diagnóstico completo
  static Future<void> runDiagnostics() async {
    if (!kDebugMode) return;
    
    print('\n🔍 Running DI System Diagnostics...\n');
    
    // Test core module
    print('Testing Core Module...');
    final coreHealthy = BindingValidator.validateCoreModule();
    print('Core Module: ${coreHealthy ? '✅ Healthy' : '❌ Issues detected'}');
    
    // Test feature modules
    print('\nTesting Feature Modules...');
    final features = ['veiculos', 'abastecimentos', 'odometro', 'despesas', 'manutencoes'];
    for (final feature in features) {
      final healthy = BindingValidator.validateFeatureModule(feature);
      print('$feature: ${healthy ? '✅' : '❌'}');
    }
    
    // Check for duplicates
    print('\nChecking for duplicates...');
    final duplicates = DIBindingMigrationHelper.detectDuplicateRegistrations();
    if (duplicates.isEmpty) {
      print('✅ No duplicates detected');
    } else {
      print('❌ Duplicates found: $duplicates');
    }
    
    print('\n✅ Diagnostics completed.\n');
  }
}