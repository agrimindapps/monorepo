// Flutter imports:
import 'package:flutter/material.dart';

class ReusableCommentDialog extends StatefulWidget {
  final String title;
  final String? origem; // Ex: "Defensivos", "Pragas", "Diagnóstico"
  final String? itemName; // Ex: "Glifosato", "Lagarta-do-cartucho"
  final String hint;
  final String? initialContent;
  final Future<void> Function(String content)? onSave;
  final VoidCallback? onCancel;
  final int minLength;
  final int maxLength;

  const ReusableCommentDialog({
    super.key,
    this.title = 'Adicionar Comentário',
    this.origem,
    this.itemName,
    this.hint = 'Digite seu comentário aqui...',
    this.initialContent,
    this.onSave,
    this.onCancel,
    this.minLength = 5,
    this.maxLength = 300,
  });

  @override
  State<ReusableCommentDialog> createState() => _ReusableCommentDialogState();
}

class _ReusableCommentDialogState extends State<ReusableCommentDialog> {
  late TextEditingController _textController;
  late ValueNotifier<String> _contentNotifier;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialContent ?? '');
    _contentNotifier = ValueNotifier<String>(widget.initialContent ?? '');

    _textController.addListener(() {
      _contentNotifier.value = _textController.text;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _contentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Semantics(
        label: 'Diálogo para adicionar novo comentário',
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: const BoxConstraints(
            maxWidth: 600,
            minHeight: 320,
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
          Semantics(
            label: 'Ícone de adicionar comentário',
            child: Icon(
              Icons.add_comment_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
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
            // Informações de origem e item
            if (widget.origem != null || widget.itemName != null)
              _buildOriginInfo(context, isDark),

            // Campo de texto
            _buildTextField(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginInfo(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.origem != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getOriginIcon(widget.origem!),
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                widget.origem!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
        if (widget.itemName != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.label_outline,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.itemName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getOriginIcon(String origem) {
    switch (origem.toLowerCase()) {
      case 'defensivos':
        return Icons.shield_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'diagnóstico':
        return Icons.medical_services_outlined;
      default:
        return Icons.comment_outlined;
    }
  }

  Widget _buildTextField(BuildContext context, bool isDark) {
    return ValueListenableBuilder<String>(
      valueListenable: _contentNotifier,
      builder: (context, content, child) {
        return Semantics(
          label: 'Campo de texto para digitar comentário',
          hint:
              'Digite seu comentário aqui, mínimo ${widget.minLength} caracteres, máximo ${widget.maxLength} caracteres',
          textField: true,
          child: TextFormField(
            controller: _textController,
            maxLines: 6,
            maxLength: widget.maxLength,
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.hint,
              labelText: 'Comentário',
              contentPadding: const EdgeInsets.all(16),
              filled: true,
            ),
          ),
        );
      },
    );
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
    return Semantics(
      label: 'Botão cancelar',
      hint: 'Cancela a criação do comentário e fecha o diálogo',
      button: true,
      child: OutlinedButton.icon(
        onPressed: () {
          widget.onCancel?.call();
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Cancelar'),
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
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark) {
    return ValueListenableBuilder<String>(
      valueListenable: _contentNotifier,
      builder: (context, content, child) {
        final trimmedContent = content.trim();

        return Semantics(
          label: 'Botão salvar comentário',
          hint: 'Salva o comentário e fecha o diálogo',
          button: true,
          child: OutlinedButton.icon(
            onPressed: () async {
              if (widget.onSave != null) {
                // Se o conteúdo estiver vazio, não salva
                if (trimmedContent.isEmpty) {
                  return;
                }

                // Se o conteúdo for muito curto, completa com espaços
                String contentToSave = trimmedContent;
                if (trimmedContent.length < widget.minLength) {
                  contentToSave =
                      trimmedContent.padRight(widget.minLength, ' ');
                }

                await widget.onSave!(contentToSave);
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
          ),
        );
      },
    );
  }
}
