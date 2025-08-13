// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../services/domain/plants/plant_limit_service.dart';
import '../controller/minhas_plantas_controller.dart';

class MinhasPlantasBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializar o serviço de limite de plantas
    Get.lazyPut<PlantLimitService>(
      () => PlantLimitService(),
    );

    // LocalLicenseService já é inicializado globalmente no app-page.dart

    Get.lazyPut<MinhasPlantasController>(
      () => MinhasPlantasController(),
    );
  }
}
