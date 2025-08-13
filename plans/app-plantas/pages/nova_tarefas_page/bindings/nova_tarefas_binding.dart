// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/nova_tarefas_controller.dart';

class NovaTarefasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NovaTarefasController>(
      () => NovaTarefasController(),
      fenix: true,
    );
  }
}
