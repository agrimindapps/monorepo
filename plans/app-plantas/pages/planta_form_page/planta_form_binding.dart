// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../database/planta_model.dart';
import 'planta_form_controller.dart';

class PlantaFormBinding extends Bindings {
  @override
  void dependencies() {
    // Pode receber PlantaModel para edição ou null para nova planta
    final PlantaModel? planta = Get.arguments as PlantaModel?;

    Get.lazyPut<PlantaFormController>(
      () => PlantaFormController(plantaOriginal: planta),
    );
  }
}
