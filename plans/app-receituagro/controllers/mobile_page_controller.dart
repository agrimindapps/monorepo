// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../router.dart';

class MobilePageController extends GetxController {
  var currentIndex = 0.obs;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void onInit() {
    super.onInit();
    // Inicialização mais segura - não navega automaticamente
    debugPrint('MobilePageController initialized');
  }
  
  void changeTabIndex(int index) {
    currentIndex.value = index;
    _navigateToTab(index);
  }
  
  void _navigateToTab(int index) {
    String route;
    switch (index) {
      case 0:
        route = AppRoutes.defensivosHome;
        break;
      case 1:
        route = AppRoutes.pragasHome;
        break;
      case 2:
        route = AppRoutes.favoritos;
        break;
      case 3:
        route = AppRoutes.comentarios;
        break;
      case 4:
        route = AppRoutes.config;
        break;
      default:
        route = AppRoutes.defensivosHome;
    }
    
    try {
      // Usa o navigator interno com ID específico para navegação aninhada
      Get.toNamed(route, id: 1);
      debugPrint('Navigated to $route with id: 1');
    } catch (e) {
      debugPrint('Navigation failed: $e');
      // Fallback sem ID se a navegação aninhada falhar
      Get.toNamed(route);
    }
  }
  
  // Método para navegação interna com parâmetros
  void navigateToRoute(String route, {dynamic arguments}) {
    Get.toNamed(
      route,
      id: 1,
      arguments: arguments,
    );
  }
  
  void goBack() {
    Get.back(id: 1);
  }
  
  @override
  void onClose() {
    // Limpar recursos para evitar memory leaks
    debugPrint('MobilePageController disposing resources');
    super.onClose();
  }
}
