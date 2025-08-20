// Package imports:
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../repository/bovinos_repository.dart';
import '../../../services/storage_service.dart';
import '../cadastro/controllers/bovinos_cadastro_controller.dart';
import '../detalhes/controllers/bovino_detalhes_controller.dart';
import '../lista/controllers/bovinos_lista_controller.dart';

class BovinosBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<BovinosRepository>(() => BovinosRepository());

    // Services
    Get.lazyPut<StorageService>(() => StorageService());
    Get.lazyPut<ImagePicker>(() => ImagePicker());

    // Controllers
    Get.lazyPut<BovinosListaController>(() => BovinosListaController());
    Get.lazyPut<BovinosCadastroController>(() => BovinosCadastroController());
    Get.lazyPut<BovinoDetalhesController>(() => BovinoDetalhesController());
  }
}
