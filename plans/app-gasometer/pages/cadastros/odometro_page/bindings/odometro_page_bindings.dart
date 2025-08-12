// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../repository/odometro_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../controller/odometro_page_controller.dart';
import '../services/odometro_event_bus.dart';
import '../services/odometro_page_service.dart';

class OdometroPageBindings extends Bindings {
  @override
  void dependencies() {
    _ensureBasicDependencies();
    _registerServices();
    _registerController();
  }

  void _ensureBasicDependencies() {
    if (!Get.isRegistered<VeiculosRepository>()) {
      Get.lazyPut<VeiculosRepository>(() => VeiculosRepository(), fenix: true);
    }
    if (!Get.isRegistered<OdometroRepository>()) {
      Get.lazyPut<OdometroRepository>(() => OdometroRepository(), fenix: true);
    }
  }

  void _registerServices() {
    if (!Get.isRegistered<OdometroEventBus>()) {
      Get.lazyPut<OdometroEventBus>(() => OdometroEventBus(), fenix: true);
    }
    if (!Get.isRegistered<OdometroPageService>()) {
      Get.lazyPut<OdometroPageService>(() => OdometroPageService(),
          fenix: true);
    }
  }

  void _registerController() {
    Get.lazyPut<OdometroPageController>(
      () => OdometroPageController(),
      fenix: true,
    );
  }
}
