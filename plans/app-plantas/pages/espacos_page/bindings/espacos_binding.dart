// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/espacos_controller.dart';

class EspacosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EspacosController>(
      () => EspacosController(),
    );
  }
}
