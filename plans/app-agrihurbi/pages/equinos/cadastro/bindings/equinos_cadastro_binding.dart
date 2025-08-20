// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/equinos_cadastro_controller.dart';

class EquinosCadastroBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EquinosCadastroController>(() => EquinosCadastroController());
  }
}
