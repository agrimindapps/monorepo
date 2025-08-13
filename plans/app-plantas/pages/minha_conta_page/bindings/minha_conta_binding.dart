// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../services/application/auth_service.dart';
import '../../../services/application/subscription_service.dart';
import '../controller/minha_conta_controller.dart';

class MinhaContaBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializar serviços de autenticação e assinatura
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<SubscriptionService>(SubscriptionService(), permanent: true);

    // LocalLicenseService já é inicializado globalmente no app-page.dart

    Get.lazyPut<MinhaContaController>(
      () => MinhaContaController(),
    );
  }
}
