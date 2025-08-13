// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/atualizacao_controller.dart';

class AtualizacaoBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AtualizacaoController>(
      () => AtualizacaoController(),
    );
  }
}
