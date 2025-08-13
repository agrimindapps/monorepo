// filepath: /Users/mac/Documents/GitHub/fnutrituti/lib/app-receituagro/services/service_provider.dart

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'premium_service.dart';

/// Classe utilitária para fornecer acesso aos serviços globais
/// e garantir que eles estejam disponíveis quando necessário.
class ServiceProvider {
  /// Retorna uma instância do PremiumService, garantindo que ela foi inicializada.
  /// Se o serviço não estiver registrado, ele será registrado automaticamente.
  static PremiumService getPremiumService() {
    if (!Get.isRegistered<PremiumService>()) {
      // Registra o serviço caso ainda não esteja registrado
      print('PremiumService não encontrado, inicializando automaticamente');
      return Get.put<PremiumService>(PremiumService())..init();
    }

    return Get.find<PremiumService>();
  }

  /// Verifica se o serviço está registrado sem causar exceção
  static bool isPremiumServiceRegistered() {
    return Get.isRegistered<PremiumService>();
  }

  /// Método genérico para verificar a existência e registrar qualquer serviço
  static T getService<T>(T Function() creator) {
    if (!Get.isRegistered<T>()) {
      return Get.put<T>(creator());
    }

    return Get.find<T>();
  }
}
