// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/premium_controller.dart';

class PremiumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumController>(
      () => PremiumController(),
    );
  }
}
