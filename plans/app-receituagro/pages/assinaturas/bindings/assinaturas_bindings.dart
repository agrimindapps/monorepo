// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/in_app_purchase_service.dart';
import '../controller/assinaturas_controller.dart';

/// Binding específico para a página de assinaturas do ReceitaAgro
class AssinaturasBindings extends Bindings {
  @override
  void dependencies() {
    // Registra o InAppPurchaseService como singleton se não estiver registrado
    if (!Get.isRegistered<InAppPurchaseService>()) {
      Get.put<InAppPurchaseService>(
        InAppPurchaseService(),
        permanent: true,
      );
    }

    // Registra o controller específico do ReceitaAgro
    Get.lazyPut<AssinaturasController>(
      () => AssinaturasController(),
      fenix: true,
    );
  }
}
