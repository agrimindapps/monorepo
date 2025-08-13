// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';

/// Widget especializado para a TabBar da tela de detalhes da planta
/// Responsável pela apresentação das abas de navegação
class PlantaDetalhesTabBar extends StatelessWidget {
  const PlantaDetalhesTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabBackgroundColor = PlantasColors.surfaceColor;
      final shadowColor = PlantasColors.shadowColor;
      final tabIndicatorColor =
          PlantasColors.primaryColor.withValues(alpha: 0.15);
      final tabSelectedColor = PlantasColors.primaryColor;
      final tabUnselectedColor = PlantasColors.textSecondaryColor;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        height: kToolbarHeight + 8.0,
        decoration: BoxDecoration(
          color: tabBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: TabBar(
            indicator: BoxDecoration(
              color: tabIndicatorColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            indicatorColor: Colors.transparent,
            labelColor: tabSelectedColor,
            unselectedLabelColor: tabUnselectedColor,
            indicatorWeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 4.0,
              vertical: 2,
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            tabs: _buildTabs(),
          ),
        ),
      );
    });
  }

  List<Tab> _buildTabs() {
    return const [
      Tab(
        icon: Icon(Icons.info_outline, size: 18),
        text: 'Visão Geral',
      ),
      Tab(
        icon: Icon(Icons.task_alt, size: 18),
        text: 'Tarefas',
      ),
      Tab(
        icon: Icon(Icons.settings, size: 18),
        text: 'Cuidados',
      ),
      Tab(
        icon: Icon(Icons.comment, size: 18),
        text: 'Comentários',
      ),
    ];
  }
}
