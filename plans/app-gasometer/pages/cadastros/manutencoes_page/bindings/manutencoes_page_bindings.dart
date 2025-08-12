// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/manutecoes_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../controller/manutencoes_page_controller.dart';

class ManutencoesPageBindings extends Bindings {
  @override
  void dependencies() {
    _ensureBasicDependencies();
    _registerController();
  }

  void _ensureBasicDependencies() {
    if (!Get.isRegistered<VeiculosRepository>()) {
      Get.lazyPut<VeiculosRepository>(() => VeiculosRepository(), fenix: true);
    }
    if (!Get.isRegistered<ManutencoesRepository>()) {
      Get.lazyPut<ManutencoesRepository>(() => ManutencoesRepository(),
          fenix: true);
    }
  }

  void _registerController() {
    Get.lazyPut<ManutencoesPageController>(
      () => ManutencoesPageController(),
      fenix: true,
    );
  }
}
