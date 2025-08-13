// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/navigation/navigation_service.dart';
import '../controller/lista_pragas_controller.dart';
import '../services/praga_data_service.dart';
import '../services/praga_filter_service.dart';
import '../services/praga_sort_service.dart';

class ListaPragasBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IPragaDataService>(() => PragaDataService());
    Get.lazyPut<IPragaFilterService>(() => PragaFilterService());
    Get.lazyPut<IPragaSortService>(() => PragaSortService());
    
    // Use NavigationService global se não estiver registrado
    if (!Get.isRegistered<NavigationService>()) {
      Get.lazyPut<NavigationService>(() => NavigationService());
    }
    
    Get.lazyPut<ListaPragasController>(
      () => ListaPragasController(
        dataService: Get.find<IPragaDataService>(),
        filterService: Get.find<IPragaFilterService>(),
        sortService: Get.find<IPragaSortService>(),
        navigationService: Get.find<NavigationService>(),
      ),
    );
  }
}
