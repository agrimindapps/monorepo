// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'i_navigation_service.dart';
import 'navigation_service.dart';

/// Binding centralizado para o NavigationService unificado
/// Garante injeção de dependência consistente em todo o módulo
class NavigationBindings extends Bindings {
  @override
  void dependencies() {
    // Registra NavigationService como singleton para todo o módulo
    Get.put<INavigationService>(NavigationService(), permanent: true);
    
    // Registra também a implementação concreta para casos específicos
    Get.put<NavigationService>(Get.find<NavigationService>(), permanent: true);
  }
}