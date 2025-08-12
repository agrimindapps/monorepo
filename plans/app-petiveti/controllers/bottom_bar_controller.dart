// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

class BottomBarController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  PageController? pageController;

  final List<({IconData icon, IconData activeIcon, String label, String route})>
      navigationItems = const [
    (
      icon: Icons.cruelty_free_outlined,
      activeIcon: Icons.cruelty_free,
      label: 'Raças',
      route: '/racas',
    ),
    (
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication,
      label: 'Bulas',
      route: '/bulas',
    ),
    (
      icon: Icons.pets_outlined,
      activeIcon: Icons.pets,
      label: 'Meu Pet',
      route: '/meupet',
    ),
    (
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate,
      label: 'Calcular',
      route: '/calcular',
    ),
    (
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    (
      icon: Icons.more_horiz,
      activeIcon: Icons.more_horiz,
      label: 'Mais',
      route: '/mais',
    ),
  ];

  void setPageController(PageController controller) {
    pageController = controller;
  }

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void navigateToIndex(int index) {
    if (index >= 0 && index < navigationItems.length) {
      selectedIndex.value = index;
      
      // Se tem PageController, usa ele (para mobile_page)
      if (pageController != null) {
        pageController!.jumpToPage(index);
      } else {
        // Senão, navega por rotas (para páginas individuais)
        final route = navigationItems[index].route;
        Get.offNamed(route);
      }
    }
  }

  void setSelectedIndexByRoute(String route) {
    final index = navigationItems.indexWhere((item) => item.route == route);
    if (index != -1) {
      selectedIndex.value = index;
    }
  }

  @override
  void onClose() {
    // Não dispose do PageController pois é gerenciado externamente
    // Apenas limpar referência
    pageController = null;
    super.onClose();
  }
}
