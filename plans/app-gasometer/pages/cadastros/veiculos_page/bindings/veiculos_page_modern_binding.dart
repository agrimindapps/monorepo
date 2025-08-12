// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../di/gasometer_di_module.dart';
import '../../../../di/modern_bindings.dart';
import '../../../../repository/veiculos_repository.dart';
import '../controller/veiculos_page_controller.dart';
import '../repository/veiculos_repository_wrapper.dart';
import '../services/service_manager.dart';
import '../services/veiculos_export_service.dart';
import '../use_cases/veiculos_use_cases.dart';

/// Binding moderno para página de Veículos - MIGRADO
/// 
/// MUDANÇAS DO SISTEMA ANTERIOR:
/// ✅ Remove duplicação de registros de repositories
/// ✅ Elimina fenix pattern problemático
/// ✅ Usa feature modules para dependências core
/// ✅ Lifecycle management adequado para controllers
/// ✅ Sem verificações manuais Get.isRegistered()
/// ✅ Memory leaks eliminados
class VeiculosPageModernBinding extends Bindings {
  @override
  void dependencies() {
    // Garante que feature module está inicializado (não duplica repositories)
    VeiculosFeatureModule.instance.registerDependencies();

    // Registra apenas dependências específicas desta página
    _registerPageServices();
    _registerPageController();
  }

  void _registerPageServices() {
    // Service Manager - específico desta página
    Get.lazyPut<VeiculosServiceManager>(
      () => VeiculosServiceManager.instance,
      // SEM fenix: permite garbage collection
    );

    // Repository Wrapper - específico desta página
    Get.lazyPut<VeiculosRepositoryWrapper>(
      () => VeiculosRepositoryWrapper(
        // Repository vem do core module - não duplica registro
        Get.find<VeiculosRepository>(),
      ),
    );

    // Export Service - específico desta página
    Get.lazyPut<VeiculosExportService>(
      () => VeiculosExportService(
        Get.find<VeiculosRepository>(),
      ),
    );

    // Use Cases - específico desta página
    Get.lazyPut<VeiculosUseCases>(
      () => VeiculosUseCases(
        Get.find<VeiculosRepository>(),
      ),
    );
  }

  void _registerPageController() {
    // Controller - será disposto quando página for removida
    Get.lazyPut<VeiculosPageController>(
      () => VeiculosPageController(),
      // SEM fenix: permite cleanup adequado
    );
  }
}

/// Exemplo de migração automática usando o ModernBindingsFactory
class VeiculosPageAutoBinding extends ModernVeiculosPageBinding {
  // Simplesmente herda do binding moderno
  // Pode adicionar customizações específicas se necessário
}