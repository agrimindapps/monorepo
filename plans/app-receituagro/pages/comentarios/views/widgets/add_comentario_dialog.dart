// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controller/comentarios_controller.dart';

class AddComentarioDialog extends StatelessWidget {
  final ComentariosController controller;
  final VoidCallback? onCancel;
  final Future<void> Function(String content)? onSave;

  const AddComentarioDialog({
    super.key,
    required this.controller,
    this.onCancel,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Semantics(
        label: 'Diálogo para adicionar novo comentário',
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(
            maxWidth: 500,
            minHeight: 280,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header do diálogo
              _buildHeader(context, isDark),

              // Conteúdo do diálogo
              _buildContent(context, isDark),

              // Botões de ação
              _buildActions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_comment_outlined,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Adicionar Comentário',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escreva seu comentário:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),

            // Campo de texto
            _buildTextField(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, bool isDark) {
    return Obx(() {
      final content = controller.state.newCommentContent;
      return TextFormField(
        initialValue: content,
        maxLines: 4,
        maxLength: 300,
        autofocus: true,
        onChanged: (value) {
          controller.updateNewCommentContent(value);
        },
        decoration: InputDecoration(
          hintText: 'Digite seu comentário aqui...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: isDark
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          counterStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    });
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão Cancelar
          _buildCancelButton(context, isDark),

          const SizedBox(width: 12),

          // Botão Salvar
          _buildSaveButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, bool isDark) {
    return OutlinedButton.icon(
      onPressed: () {
        controller.stopCreatingNewComentario();
        onCancel?.call();
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.close, size: 16),
      label: const Text('Cancelar'),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isDark ? Theme.of(context).colorScheme.onSurface : Colors.grey[700],
        side: BorderSide(
          color: isDark
              ? Theme.of(context).colorScheme.outline
              : Colors.grey[400]!,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark) {
    return Obx(() {
      final content = controller.state.newCommentContent;
      final trimmedContent = content.trim();

      return OutlinedButton.icon(
        onPressed: () async {
          if (onSave != null) {
            // Se o conteúdo estiver vazio ou muito curto, não salva
            if (trimmedContent.isEmpty) {
              // Mostra feedback visual ou sonoro que o campo está vazio
              return;
            }

            // Se o conteúdo for muito curto, completa com espaços ou uma mensagem padrão
            String contentToSave = trimmedContent;
            if (trimmedContent.length < 5) {
              contentToSave = trimmedContent.padRight(5, ' ');
            }

            await onSave!(contentToSave);
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Salvar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey[700],
          side: BorderSide(
            color: isDark
                ? Theme.of(context).colorScheme.outline
                : Colors.grey[400]!,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }
}
