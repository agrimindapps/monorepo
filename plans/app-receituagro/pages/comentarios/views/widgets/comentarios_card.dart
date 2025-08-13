// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/comentarios_models.dart';
import '../../../../widgets/reusable_comment_dialog.dart';
import '../../controller/comentarios_controller.dart';

/// Widget responsável por exibir e editar um comentário individual
/// 
/// Este widget usa estado reativo centralizado no controller, sem manter estado local
class ComentariosCard extends StatelessWidget {
  /// Comentário a ser exibido (null para novo comentário)
  final Comentarios? comentario;
  
  /// Nome da ferramenta/contexto do comentário
  final String? ferramenta;
  
  /// Identificador do contexto do comentário  
  final String? pkIdentificador;
  
  /// Callback executado ao cancelar edição
  final VoidCallback? onCancel;
  
  /// Callback executado ao salvar comentário
  /// Recebe o conteúdo do comentário como parâmetro
  final Function(String content)? onSave;
  
  /// Callback executado ao excluir comentário
  final VoidCallback? onDelete;
  
  /// Callback executado ao editar comentário
  /// Recebe o comentário e novo conteúdo como parâmetros
  final Function(Comentarios comentario, String newContent)? onEdit;
  
  /// Define se o card está em modo fixo (sempre editando)
  final bool isFixed;
  
  /// Controller para gerenciar o estado reativo
  final ComentariosController controller;

  const ComentariosCard({
    super.key,
    this.comentario,
    required this.ferramenta,
    required this.pkIdentificador,
    this.onSave,
    this.onEdit,
    this.onDelete,
    this.onCancel,
    this.isFixed = false,
    required this.controller,
  });

  /// ID único para o comentário (usado para gerenciar estado)
  String get _comentarioId => comentario?.id ?? 'new_comment';

  /// Abre dialog para editar comentário
  void _openEditDialog(BuildContext context) {
    if (comentario == null) return;
    
    // Extrai informações de origem e item do ferramenta
    final ferramentaParts = comentario!.ferramenta.split(' - ');
    final origem = ferramentaParts.isNotEmpty ? ferramentaParts[0] : null;
    final itemName = ferramentaParts.length > 1 ? ferramentaParts[1] : null;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReusableCommentDialog(
        title: 'Editar Comentário',
        origem: origem,
        itemName: itemName,
        initialContent: comentario!.conteudo,
        onSave: (content) async {
          if (onEdit != null) {
            await onEdit!(comentario!, content);
          }
        },
        onCancel: () {
          // Não precisa fazer nada específico no cancelamento
        },
      ),
    );
  }

  /// Valida e salva o comentário
  void _saveComentario(String content) {
    if (content.trim().length < 5) {
      Get.snackbar(
        'Erro',
        'O comentário deve ter pelo menos 5 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    if (content.trim().length > 300) {
      Get.snackbar(
        'Erro',
        'O comentário não pode ter mais que 300 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Executa callback apropriado baseado no modo
    if (comentario == null) {
      // Novo comentário
      onSave?.call(content);
      if (isFixed) {
        controller.stopCreatingNewComentario();
        controller.startCreatingNewComentario(); // Reinicia para novo comentário
      }
    } else {
      // Edição de comentário existente
      onEdit?.call(comentario!, content);
    }
  }

  /// Cancela a edição
  void _cancelComentario() {
    if (comentario == null) {
      controller.stopCreatingNewComentario();
    }
    
    onCancel?.call();
  }

  /// Executa a exclusão do comentário
  void _deleteComentario() {
    if (comentario != null) {
      controller.markComentarioAsDeleted(_comentarioId);
      onDelete?.call();
    }
  }

  /// Formata data para exibição
  String _formatData(DateTime data) {
    final date = data.toString().substring(0, 10).split('-').reversed.join('/');
    return date;
  }

  /// Constrói a interface de edição
  Widget _buildEditingInterface(String currentContent) {
    return Column(
      children: [
        TextFormField(
          initialValue: currentContent,
          maxLines: 4,
          maxLength: 300,
          autofocus: comentario == null,
          onChanged: (value) {
            if (comentario == null) {
              controller.updateNewCommentContent(value);
            } else {
              controller.updateEditingContent(_comentarioId, value);
            }
          },
          decoration: InputDecoration(
            hintText: 'Digite seu comentário',
            contentPadding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            filled: true,
            fillColor: Get.theme.scaffoldBackgroundColor,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            counterStyle: const TextStyle(color: Colors.grey),
          ),
          validator: (value) {
            if (value == null || value.trim().length < 5) {
              return 'Mínimo 5 caracteres';
            }
            return null;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              color: Get.theme.primaryColorDark,
              icon: const Icon(Icons.cancel),
              onPressed: _cancelComentario,
              tooltip: 'Cancelar',
            ),
            IconButton(
              color: Get.theme.primaryColorDark,
              icon: const Icon(Icons.save),
              onPressed: () => _saveComentario(currentContent),
              tooltip: 'Salvar',
            ),
          ],
        ),
      ],
    );
  }

  /// Constrói a interface de visualização
  Widget _buildViewingInterface() {
    if (comentario == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com origem e data
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: _buildOriginInfo(),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 1,
              child: _buildDateInfo(),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        // Conteúdo do comentário
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
          child: Text(
            comentario!.conteudo,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  /// Constrói informações de origem
  Widget _buildOriginInfo() {
    if (comentario == null) return const SizedBox.shrink();

    final ferramenta = comentario!.ferramenta;
    final parts = ferramenta.split(' - ');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          parts[0],
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
        ),
        if (parts.length > 1)
          Text(
            parts[1],
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Constrói informações da data
  Widget _buildDateInfo() {
    if (comentario == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        _formatData(comentario!.createdAt),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.state;
      
      // Verifica se foi deletado
      if (comentario != null && state.isDeletedComentario(_comentarioId)) {
        return const SizedBox.shrink();
      }

      // Comentários existentes sempre mostram interface de visualização
      // Novos comentários (quando comentario == null) mostram interface de edição
      final isNewComment = comentario == null;
      
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: isNewComment 
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                  child: _buildEditingInterface(state.newCommentContent),
                ),
              )
            : Dismissible(
                key: Key(_comentarioId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Tem certeza que deseja excluir este comentário?'),
                        actions: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Excluir'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _deleteComentario();
                },
                child: GestureDetector(
                  onTap: () => _openEditDialog(Get.context!),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                      child: _buildViewingInterface(),
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
