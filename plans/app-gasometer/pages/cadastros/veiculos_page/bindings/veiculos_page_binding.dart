// External packages

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/veiculos_repository.dart';
import '../controller/veiculos_page_controller.dart';
import '../repository/veiculos_repository_wrapper.dart';
import '../services/service_manager.dart';
import '../services/veiculos_export_service.dart';
import '../use_cases/veiculos_use_cases.dart';

// Internal dependencies

// Local imports

/// ❌ DEPRECATED: Use VeiculosPageModernBinding
/// 
/// PROBLEMAS RESOLVIDOS no sistema moderno:
/// - ✅ Elimina duplicação de registros de repositories
/// - ✅ Remove fenix pattern problemático que causava memory leaks  
/// - ✅ Acaba com verificações manuais Get.isRegistered()
/// - ✅ Lifecycle management adequado para controllers
/// - ✅ Facilita testes com utilities específicas
/// 
/// MIGRAÇÃO: Substitua por VeiculosPageModernBinding em router.dart
@Deprecated('Use VeiculosPageModernBinding - resolve memory leaks e duplicações')
class VeiculosPageBinding extends Bindings {
  @override
  void dependencies() {
    _initializeServiceManager();
    _ensureBasicDependencies();
    _registerServices();
    _registerController();
  }

  /// Initialize ServiceManager for coordinated service lifecycle
  void _initializeServiceManager() {
    // Initialize ServiceManager to coordinate all service lifecycles
    Get.putAsync<VeiculosServiceManager>(
      () async {
        await VeiculosServiceManager.initialize();
        return VeiculosServiceManager.instance;
      },
      permanent: true, // Keep alive for app lifetime
    );
  }

  /// Garante que dependências básicas estejam registradas
  void _ensureBasicDependencies() {
    if (!Get.isRegistered<VeiculosRepository>()) {
      Get.lazyPut<VeiculosRepository>(
        () => VeiculosRepository(),
        fenix: true, // Permite recriação automática se necessário
      );
    }

    // Register repository wrapper with Result pattern
    if (!Get.isRegistered<VeiculosRepositoryWrapper>()) {
      Get.lazyPut<VeiculosRepositoryWrapper>(
        () => VeiculosRepositoryWrapper(Get.find<VeiculosRepository>()),
        fenix: true,
      );
    }
  }

  /// Registra services e use cases
  void _registerServices() {
    // Register use cases
    Get.lazyPut<VeiculosUseCases>(
      () => VeiculosUseCases(Get.find<VeiculosRepository>()),
      fenix: true,
    );

    // Register export service
    Get.lazyPut<VeiculosExportService>(
      () => VeiculosExportService(Get.find<VeiculosRepository>()),
      fenix: true,
    );
  }

  /// Registra o controller da página
  void _registerController() {
    // Register page controller with integrated functionality
    Get.lazyPut<VeiculosPageController>(
      () => VeiculosPageController(),
      fenix: true,
    );
  }

  /// Verifica se todas as dependências críticas estão inicializadas
  bool isFullyInitialized() {
    return Get.isRegistered<VeiculosServiceManager>() &&
        Get.isRegistered<VeiculosRepository>() &&
        Get.isRegistered<VeiculosRepositoryWrapper>() &&
        Get.isRegistered<VeiculosUseCases>() &&
        Get.isRegistered<VeiculosExportService>() &&
        Get.isRegistered<VeiculosPageController>();
  }
}
