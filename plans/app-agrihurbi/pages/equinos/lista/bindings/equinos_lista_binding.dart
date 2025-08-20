// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/equinos_lista_controller.dart';

class EquinosListaBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EquinosListaController>(() => EquinosListaController());
  }
}
