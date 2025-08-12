// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/themes/manager.dart';
import '../controllers/bottom_bar_controller.dart';

class VetBottomBarWidget extends StatelessWidget {
  const VetBottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomBarController = Get.find<BottomBarController>();

    return Obx(() {
      final isDark = ThemeManager().isDark.value;

      return BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8),
        selectedItemColor:
            isDark ? Colors.purple.shade400 : Colors.purple.shade700,
        unselectedItemColor:
            isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        currentIndex: bottomBarController.selectedIndex.value,
        onTap: (index) => bottomBarController.navigateToIndex(index),
        items: bottomBarController.navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      );
    });
  }
}
