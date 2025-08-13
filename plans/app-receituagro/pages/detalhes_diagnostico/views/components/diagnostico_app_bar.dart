// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: AppBar Componente
// DESCRIÇÃO: Barra de aplicação customizada para tela de diagnóstico
// RESPONSABILIDADES: Controles de fonte, favoritos, ações da toolbar
// DEPENDÊNCIAS: Controller principal, widgets de controle
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controller/detalhes_diagnostico_controller.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/font_size_controls.dart';

class DiagnosticoAppBar extends StatelessWidget {
  final DetalhesDiagnosticoController controller;

  const DiagnosticoAppBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => FontSizeControlsWidget(
              fontSize: controller.fontSize.value,
              onIncrease: () => _changeFontSize(2),
              onDecrease: () => _changeFontSize(-2),
            )),
        const SizedBox(width: 8),
        Obx(() => FavoriteButtonWidget(
              isFavorite: controller.isFavorite.value,
              onToggle: controller.toggleFavorite,
            )),
      ],
    );
  }

  void _changeFontSize(double delta) {
    final newSize = (controller.fontSize.value + delta).clamp(12.0, 24.0);
    controller.setFontSize(newSize);
  }
}
