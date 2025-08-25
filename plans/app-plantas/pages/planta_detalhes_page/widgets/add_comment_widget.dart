// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para adição de comentários
/// Responsável pela interface de entrada de novos comentários
class AddCommentWidget extends StatelessWidget {
  final PlantaDetalhesController controller;

  const AddCommentWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cores = {
        'primaria': PlantasColors.primaryColor,
        'textoClaro': PlantasColors.surfaceColor,
        'fundoCard': PlantasColors.surfaceColor,
        'borda': PlantasColors.borderColor,
        'texto': PlantasColors.textColor,
      };

      return Row(
        children: [
          Expanded(
            child: _buildCommentTextField(cores),
          ),
          const SizedBox(width: 12.0),
          _buildSendButton(cores),
        ],
      );
    });
  }

  Widget _buildCommentTextField(
    Map<String, Color> cores,
  ) {
    return TextField(
      controller: controller.comentarioController,
      decoration: InputDecoration(
        hintText: 'Adicionar comentário...',
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: cores['borda']!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: cores['borda']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: cores['primaria']!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        filled: true,
        fillColor: cores['fundoCard'],
      ),
      maxLines: null,
      minLines: 1,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 14,
        color: cores['texto'],
        height: 1.4,
      ),
    );
  }

  Widget _buildSendButton(
    Map<String, Color> cores,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores['primaria']!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: IconButton(
        onPressed: controller.adicionarComentario,
        icon: const Icon(Icons.send),
        color: cores['primaria'],
        iconSize: 20,
        padding: const EdgeInsets.all(12.0),
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        tooltip: 'Adicionar comentário',
      ),
    );
  }
}
