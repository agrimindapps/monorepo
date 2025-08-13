// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/comentario_model.dart';
import '../controller/planta_detalhes_controller.dart';
import 'add_comment_widget.dart';
import 'comment_item_widget.dart';

/// Widget especializado para a seção de comentários
/// Responsável pela listagem e adição de comentários da planta
class ComentariosSectionWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final List<ComentarioModel> comentarios;
  final bool temComentarios;

  const ComentariosSectionWidget({
    super.key,
    required this.controller,
    required this.comentarios,
    required this.temComentarios,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cores = {
        'primaria': PlantasColors.primaryColor,
        'fundoCard': PlantasColors.surfaceColor,
        'texto': PlantasColors.textColor,
        'textoSecundario': PlantasColors.textSecondaryColor,
        'shadow': PlantasColors.shadowColor,
        'infoClaro': PlantasColors.primaryColor.withValues(alpha: 0.1),
        'sucessoClaro': Colors.green.withValues(alpha: 0.1),
        'info': PlantasColors.primaryColor,
        'sucesso': Colors.green,
      };

      final estilos = {
        'cardTitle': TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: cores['texto'],
        ),
        'commentCounter': const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
        'emptyStateTitle': TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: cores['texto'],
        ),
        'emptyStateSubtitle': TextStyle(
          fontSize: 14.0,
          color: cores['textoSecundario'],
        ),
      };

      final decoracao = BoxDecoration(
        color: cores['fundoCard'],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: cores['shadow']!,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      );

      return Container(
        width: double.infinity,
        decoration: decoracao,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(estilos, cores),
            _buildAddCommentSection(),
            if (temComentarios) ...[
              const SizedBox(height: 8.0),
              _buildCommentsList(),
            ] else
              _buildEmptyState(cores, estilos),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.comment,
            color: cores['primaria'],
            size: 24,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Comentários',
              style: estilos['cardTitle'],
            ),
          ),
          _buildCommentCounter(estilos, cores),
        ],
      ),
    );
  }

  Widget _buildCommentCounter(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: comentarios.isEmpty ? cores['infoClaro'] : cores['sucessoClaro'],
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: comentarios.isEmpty ? cores['info']! : cores['sucesso']!,
          width: 1,
        ),
      ),
      child: Text(
        comentarios.isEmpty ? 'Vazio' : '${comentarios.length}',
        style: estilos['commentCounter']?.copyWith(
          color: comentarios.isEmpty ? cores['info'] : cores['sucesso'],
        ),
      ),
    );
  }

  Widget _buildAddCommentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AddCommentWidget(
        controller: controller,
      ),
    );
  }

  Widget _buildCommentsList() {
    return Column(
      children: [
        ...comentarios.map((comentario) => Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                8.0,
                16.0,
                0,
              ),
              child: CommentItemWidget(
                controller: controller,
                comentario: comentario,
              ),
            )),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildEmptyState(
    Map<String, Color> cores,
    Map<String, TextStyle> estilos,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        8.0,
        16.0,
        16.0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.comment_outlined,
              size: 64,
              color: cores['textoSecundario'],
            ),
            const SizedBox(height: 16.0),
            Text(
              'Nenhum comentário ainda',
              style: estilos['emptyStateTitle'],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Adicione suas observações e acompanhe o desenvolvimento da sua planta!',
              style: estilos['emptyStateSubtitle'],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
