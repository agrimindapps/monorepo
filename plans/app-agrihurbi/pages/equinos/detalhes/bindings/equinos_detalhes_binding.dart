// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/equinos_detalhes_controller.dart';

class EquinosDetalhesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EquinosDetalhesController>(() => EquinosDetalhesController());
  }
}
