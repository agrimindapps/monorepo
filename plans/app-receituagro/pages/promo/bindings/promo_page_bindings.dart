// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/promo_page_controller.dart';

class PromoPageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PromoPageController>(
      () => PromoPageController(),
    );
  }
}
