// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/pragas_repository.dart';
import '../controller/lista_pragas_por_cultura_controller.dart';
import '../services/lista_pragas_service.dart';

class ListaPragasPorCulturaBindings extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<PragasRepository>(() => PragasRepository());
    
    // Service
    Get.lazyPut<ListaPragasService>(
      () => ListaPragasService(Get.find<PragasRepository>()),
    );
    
    // Controller
    Get.lazyPut<ListaPragasPorCulturaController>(
      () => ListaPragasPorCulturaController(),
    );
  }
}
