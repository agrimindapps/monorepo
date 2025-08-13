// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/comentario_model.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para exibir um item de comentário
/// Responsável pela apresentação e ações de um comentário individual
class CommentItemWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final ComentarioModel comentario;

  const CommentItemWidget({
    super.key,
    required this.controller,
    required this.comentario,
  });

  @override
  Widget build(BuildContext context) {
    final cores = {
      'fundoSecundario': PlantasColors.backgroundColor,
      'texto': PlantasColors.textColor,
      'textoSecundario': PlantasColors.textSecondaryColor,
      'erro': Colors.red,
      'borda': PlantasColors.borderColor,
      'erroClaro': Colors.red.withValues(alpha: 0.1),
      'textoClaro': PlantasColors.surfaceColor,
    };

    final estilos = {
      'commentAuthor': TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: cores['texto'],
      ),
      'commentText': TextStyle(
        fontSize: 14.0,
        color: cores['texto'],
      ),
      'commentDate': TextStyle(
        fontSize: 12.0,
        color: cores['textoSecundario'],
      ),
      'commentContent': TextStyle(
        fontSize: 14.0,
        color: cores['texto'],
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cores['fundoSecundario'],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: cores['borda']!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentContent(estilos, cores),
          const SizedBox(height: 8.0),
          _buildCommentFooter(estilos, cores),
        ],
      ),
    );
  }

  Widget _buildCommentContent(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Text(
      comentario.conteudo,
      style: estilos['commentContent']?.copyWith(
        color: cores['texto'],
        height: 1.4,
      ),
    );
  }

  Widget _buildCommentFooter(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Row(
      children: [
        _buildCommentDate(estilos, cores),
        const Spacer(),
        _buildDeleteButton(cores),
      ],
    );
  }

  Widget _buildCommentDate(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    final dataExibicao = comentario.dataCriacao ??
        DateTime.fromMillisecondsSinceEpoch(comentario.createdAt);

    return Text(
      _formatCommentDate(dataExibicao),
      style: estilos['commentDate']?.copyWith(
        color: cores['textoSecundario'],
      ),
    );
  }

  Widget _buildDeleteButton(
    Map<String, Color> cores,
  ) {
    return GestureDetector(
      onTap: () => _confirmarRemocaoComentario(),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: cores['erroClaro'],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          Icons.delete_outline,
          size: 16,
          color: cores['erro'],
        ),
      ),
    );
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _confirmarRemocaoComentario() {
    final context = Get.context!;
    final cores = {
      'texto': PlantasColors.textColor,
      'textoSecundario': PlantasColors.textSecondaryColor,
      'erro': Colors.red,
      'textoClaro': PlantasColors.surfaceColor,
    };

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Remover Comentário',
          style: TextStyle(
            color: cores['texto'],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja remover este comentário? Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: cores['textoSecundario'],
          ),
        ),
        actions: [
          _buildCancelButton(cores),
          _buildConfirmButton(cores),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildCancelButton(
    Map<String, Color> cores,
  ) {
    return TextButton(
      onPressed: () => Get.back(),
      style: TextButton.styleFrom(
        foregroundColor: cores['textoSecundario'],
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: const Text('Cancelar'),
    );
  }

  Widget _buildConfirmButton(
    Map<String, Color> cores,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isRemoving = false;

        return ElevatedButton(
          onPressed: isRemoving
              ? null
              : () async {
                  setState(() {
                    isRemoving = true;
                  });

                  try {
                    await controller.removerComentario(comentario);

                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                  } catch (e) {
                    setState(() {
                      isRemoving = false;
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: cores['erro'],
            foregroundColor: cores['textoClaro'],
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: isRemoving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(cores['textoClaro']!),
                  ),
                )
              : const Text('Remover'),
        );
      },
    );
  }
}
