// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/plantas_colors.dart';
import '../pages/minha_conta_page/index.dart';
import '../pages/minhas_plantas_page/index.dart';
import '../pages/nova_tarefas_page/bindings/nova_tarefas_binding.dart';
import '../pages/nova_tarefas_page/views/nova_tarefas_view.dart';

enum BottomNavPage { tarefas, plantas, conta }

class AppBottomNavWidget extends StatelessWidget {
  final BottomNavPage currentPage;
  final VoidCallback? onTarefasTap;
  final VoidCallback? onPlantasTap;
  final VoidCallback? onContaTap;

  const AppBottomNavWidget({
    super.key,
    required this.currentPage,
    this.onTarefasTap,
    this.onPlantasTap,
    this.onContaTap,
  });

  void _navigateToTarefas() {
    if (currentPage != BottomNavPage.tarefas) {
      Get.offAll(
        () => const NovaTarefasView(),
        binding: NovaTarefasBinding(),
      );
    }
  }

  void _navigateToMinhasPlantas() {
    if (currentPage != BottomNavPage.plantas) {
      Get.offAll(
        () => const MinhasPlantasView(),
        binding: MinhasPlantasBinding(),
      );
    }
  }

  void _navigateToMinhaConta() {
    if (currentPage != BottomNavPage.conta) {
      Get.offAll(
        () => const MinhaContaView(),
        binding: MinhaContaBinding(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          height: 80,
          decoration: BoxDecoration(
            color: PlantasColors.surfaceColor,
            border: Border(
              top: BorderSide(
                color: PlantasColors.borderColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.format_list_bulleted,
                title: 'Tarefas',
                isSelected: currentPage == BottomNavPage.tarefas,
                onTap: onTarefasTap ?? () => _navigateToTarefas(),
              ),
              _buildNavItem(
                icon: Icons.eco,
                title: 'Minhas plantas',
                isSelected: currentPage == BottomNavPage.plantas,
                onTap: onPlantasTap ?? () => _navigateToMinhasPlantas(),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                title: 'Minha conta',
                isSelected: currentPage == BottomNavPage.conta,
                onTap: onContaTap ?? () => _navigateToMinhaConta(),
              ),
            ],
          ),
        ));
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final color = isSelected
            ? PlantasColors.primaryColor
            : PlantasColors.subtitleColor;

        return Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
