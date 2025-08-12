// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/odometro_cadastro_form_controller.dart';

/// Binding para o controller de cadastro de odômetro
///
/// Responsável por gerenciar o ciclo de vida do OdometroCadastroFormController
/// de forma adequada usando Get.lazyPut para evitar vazamentos de memória
class OdometroCadastroFormBinding extends Bindings {
  @override
  void dependencies() {
    // Usa lazyPut para criar o controller apenas quando necessário
    // e automaticamente limpa quando não está mais em uso
    Get.lazyPut<OdometroCadastroFormController>(
      () => OdometroCadastroFormController(),
      // fenix: true permite que o controller seja recriado se necessário
      fenix: true,
    );
  }
}
