import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/appbar.dart';
import '../providers/comentarios_providers.dart';
import '../widgets/comentario_card.dart';
import '../widgets/empty_comentarios_widget.dart';
import '../widgets/error_comentarios_widget.dart';

/// Page that displays all comentarios
/// Using Riverpod for state management following Clean Architecture
class ComentariosPage extends ConsumerWidget {
  const ComentariosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch comentarios state
    final comentariosAsync = ref.watch(comentariosNotifierProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTitleBar(context, ref),
                  const SizedBox(height: 8),
                  _buildComentariosList(context, ref, comentariosAsync),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Comentários',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(context),
        ),
      ],
    );
  }

  Widget _buildComentariosList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> comentariosAsync,
  ) {
    return comentariosAsync.when(
      data: (comentarios) {
        if (comentarios.isEmpty) {
          return const EmptyComentariosWidget();
        }

        return ListView.builder(
          itemCount: comentarios.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final comentario = comentarios[index];
            return ComentarioCard(
              comentario: comentario,
              onEdit: () => _handleEdit(context, ref, comentario),
              onDelete: () => _handleDelete(context, ref, comentario.id),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => ErrorComentariosWidget(
        error: error.toString(),
        onRetry: () => ref.invalidate(comentariosNotifierProvider),
      ),
    );
  }

  Future<void> _handleEdit(
    BuildContext context,
    WidgetRef ref,
    dynamic comentario,
  ) async {
    // TODO: Implement edit dialog
    // For now, just show a snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Editar comentário (em desenvolvimento)')),
      );
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este comentário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(comentariosNotifierProvider.notifier).deleteComentario(id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentário removido com sucesso')),
        );
      }
    }
  }

  Future<void> _showInfoDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentários locais'),
        content: const SizedBox(
          width: 400,
          child: Text(
            'Os comentários são locais e pessoais, ou seja, '
            'não são compartilhados com outros usuários. '
            'Você pode adicionar, editar e excluir comentários livremente.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
