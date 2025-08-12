// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/despesas_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../controller/despesas_page_controller.dart';

class DespesasPageBindings extends Bindings {
  @override
  void dependencies() {
    _ensureBasicDependencies();
    _registerController();
  }

  void _ensureBasicDependencies() {
    if (!Get.isRegistered<VeiculosRepository>()) {
      Get.lazyPut<VeiculosRepository>(() => VeiculosRepository(), fenix: true);
    }
    if (!Get.isRegistered<DespesasRepository>()) {
      Get.lazyPut<DespesasRepository>(() => DespesasRepository(), fenix: true);
    }
  }

  void _registerController() {
    // Register page controller with integrated functionality
    Get.lazyPut<DespesasPageController>(
      () => DespesasPageController(),
      fenix: true,
    );
  }
}
