// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/pragas_repository.dart';
import '../controller/lista_culturas_controller.dart';

class ListaCulturasBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PragasRepository>(() => PragasRepository());
    Get.lazyPut<ListaCulturasController>(
      () => ListaCulturasController(),
    );
  }
}
