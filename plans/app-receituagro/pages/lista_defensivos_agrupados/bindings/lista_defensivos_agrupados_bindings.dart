// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/database_repository.dart';
import '../../../repository/defensivos_repository.dart';
import '../controller/lista_defensivos_agrupados_controller.dart';
import '../services/monitoring_service.dart';

class ListaDefensivosAgrupadosBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatabaseRepository>(() => DatabaseRepository());
    Get.lazyPut<DefensivosRepository>(() => DefensivosRepository());
    Get.lazyPut<IMonitoringService>(() => MonitoringService());
    Get.lazyPut<ListaDefensivosAgrupadosController>(
      () => ListaDefensivosAgrupadosController(
        monitoringService: Get.find<IMonitoringService>(),
      ),
    );
  }
}
