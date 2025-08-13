// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/comentarios_controller.dart';
import '../services/comentarios_service.dart';

class ComentariosBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComentariosService>(() => ComentariosService());
    Get.lazyPut<ComentariosController>(() => ComentariosController());
  }
}
