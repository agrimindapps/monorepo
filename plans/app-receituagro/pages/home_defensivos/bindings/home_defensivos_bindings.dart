// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/defensivos_repository.dart';
import '../controller/home_defensivos_controller.dart';

/// Bindings para a página home de defensivos
/// Implementa dependency injection seguindo padrão GetX
class HomeDefensivosBindings extends Bindings {
  @override
  void dependencies() {
    // Garantir que dependências básicas estejam disponíveis
    _ensureBasicDependencies();
    
    // Registrar controller
    _registerController();
  }

  void _ensureBasicDependencies() {
    if (!Get.isRegistered<DefensivosRepository>()) {
      Get.lazyPut<DefensivosRepository>(() => DefensivosRepository());
    }
  }

  void _registerController() {
    Get.lazyPut<HomeDefensivosController>(
      () => HomeDefensivosController(),
      fenix: true,
    );
  }
}
