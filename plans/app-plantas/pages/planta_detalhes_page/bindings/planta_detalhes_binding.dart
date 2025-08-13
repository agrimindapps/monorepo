// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../database/planta_model.dart';
import '../controller/planta_detalhes_controller.dart';

class PlantaDetalhesBinding extends Bindings {
  @override
  void dependencies() {
    final PlantaModel planta = Get.arguments as PlantaModel;
    Get.lazyPut<PlantaDetalhesController>(
      () => PlantaDetalhesController(planta: planta),
    );
  }
}
