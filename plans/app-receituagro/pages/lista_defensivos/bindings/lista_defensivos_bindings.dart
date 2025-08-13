// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/navigation/i_navigation_service.dart';
import '../../../repository/defensivos_repository.dart';
import '../controller/lista_defensivos_controller.dart';
import '../interfaces/i_filter_service.dart';
import '../interfaces/i_scroll_service.dart';
import '../services/filter_service.dart';
import '../services/scroll_service.dart';

class ListaDefensivosBindings extends Bindings {
  @override
  void dependencies() {
    // Registrar repository
    Get.lazyPut<DefensivosRepository>(() => DefensivosRepository());

    // Registrar services
    Get.lazyPut<IFilterService>(() => FilterService());
    Get.lazyPut<IScrollService>(() => ScrollService());

    // Registrar controller
    Get.lazyPut<ListaDefensivosController>(
      () => ListaDefensivosController(
        repository: Get.find<DefensivosRepository>(),
        filterService: Get.find<IFilterService>(),
        scrollService: Get.find<IScrollService>(),
        navigationService: Get.find<INavigationService>(),
      ),
    );
  }
}
