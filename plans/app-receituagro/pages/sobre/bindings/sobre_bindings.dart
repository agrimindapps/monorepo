// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/sobre_controller.dart';

class SobreBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SobreController>(
      () => SobreController(),
    );
  }
}
