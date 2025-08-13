// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/planta_model.dart';
import '../../../services/shared/image_service.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para o SliverAppBar da tela de detalhes da planta
/// Responsável pela apresentação do cabeçalho com imagem, nome e ações
class PlantaDetalhesAppBar extends StatelessWidget {
  final PlantaDetalhesController controller;

  const PlantaDetalhesAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SliverAppBar(
        expandedHeight: 300,
        floating: false,
        pinned: true,
        backgroundColor: PlantasColors.backgroundColor,
        leading: _buildBackButton(context),
        actions: [
          _buildOptionsMenu(context),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: _buildAppBarBackground(context),
          titlePadding: const EdgeInsets.only(
            left: 16.0,
            bottom: 12.0,
            right: 32.0,
          ),
          title: _buildPlantTitle(controller.plantaAtual.value),
        ),
      );
    });
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: PlantasColors.surfaceColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: PlantasColors.textColor,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: PlantasColors.surfaceColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: PlantasColors.textColor,
          size: 20,
        ),
        color: PlantasColors.cardColor,
        surfaceTintColor: PlantasColors.surfaceColor,
        shadowColor: PlantasColors.shadowColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        itemBuilder: (context) => [
          _buildMenuOption(
            'editar',
            'Editar planta',
            Icons.edit_outlined,
            PlantasColors.textColor,
          ),
          _buildMenuOption(
            'remover',
            'Remover planta',
            Icons.delete_outline,
            Colors.red,
          ),
        ],
        onSelected: (value) => _handleMenuAction(value),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuOption(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildAppBarBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PlantasColors.primaryColor,
            PlantasColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: _buildPlantImage(controller.plantaAtual.value),
    );
  }

  Widget _buildPlantImage(PlantaModel? planta) {
    if (planta != null &&
        planta.fotoBase64 != null &&
        planta.fotoBase64!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ImageService.base64ToImage(
                planta.fotoBase64,
                fit: BoxFit.cover,
              ) ??
              _buildDefaultPlantIcon(),
          // Overlay gradient para melhor legibilidade do título
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ],
      );
    }

    return _buildDefaultPlantIcon();
  }

  Widget _buildDefaultPlantIcon() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.eco,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlantTitle(PlantaModel? planta) {
    if (planta == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        planta.nome ?? 'Planta',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black,
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'editar':
        controller.editarPlanta();
        break;
      case 'remover':
        controller.removerPlanta();
        break;
    }
  }
}
