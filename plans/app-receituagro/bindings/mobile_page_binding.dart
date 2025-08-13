// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/mobile_page_controller.dart';

class MobilePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobilePageController>(() => MobilePageController());
  }
}
