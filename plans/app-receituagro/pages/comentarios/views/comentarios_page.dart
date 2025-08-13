// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../../../widgets/reusable_comment_dialog.dart';
import '../controller/comentarios_controller.dart';
import 'widgets/comments_list_widget.dart';
import 'widgets/empty_comments_state.dart';
import 'widgets/search_comments_widget.dart';

class ComentariosPage extends GetView<ComentariosController> {
  const ComentariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(context, isDark),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ComentariosWidget(
                      controller: controller,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        final state = controller.state;
        final maxComentarios = state.maxComentarios;
        final canAdd = state.quantComentarios < maxComentarios;

        // Só mostra o botão se pode adicionar comentários
        if (maxComentarios > 0 && canAdd) {
          return FloatingActionButton(
            onPressed: () => _onAddComentario(context),
            tooltip: 'Adicionar comentário',
            child: const Icon(Icons.add),
          );
        }

        return const SizedBox.shrink();
      }),
      bottomNavigationBar: const BottomNavigator(
        overrideIndex: 3, // Comentários
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Obx(() => ModernHeaderWidget(
          title: 'Comentários',
          subtitle: _getHeaderSubtitle(),
          leftIcon: FontAwesome.comment_dots_solid,
          rightIcon: Icons.info_outline,
          isDark: isDark,
          showBackButton: false,
          showActions: true,
          onRightIconPressed: () => _showInfoDialog(context),
        ));
  }

  String _getHeaderSubtitle() {
    final state = controller.state;

    if (state.isLoading) {
      return 'Carregando comentários...';
    }

    final total = state.comentarios.length;

    if (total > 0) {
      return '$total comentários';
    }

    return 'Suas anotações pessoais';
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Comentários locais'),
          content: const Text(
              'Os comentários são locais e pessoais, ou seja, não são compartilhados com outros usuários.\n\n• Para editar: toque no comentário\n• Para excluir: arraste o comentário para o lado'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Erro ao exibir diálogo de informações: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível exibir as informações: [$e]'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onAddComentario(BuildContext context) {
    controller.startCreatingNewComentario();
    _showAddComentarioDialog(context);
  }

  Future<void> _showAddComentarioDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReusableCommentDialog(
        title: 'Adicionar Comentário',
        origem: 'Comentários',
        itemName: 'Comentário direto',
        onSave: (content) async {
          await controller.onCardSave(content);
        },
        onCancel: () {
          controller.stopCreatingNewComentario();
        },
      ),
    );
  }
}

class ComentariosWidget extends StatelessWidget {
  final ComentariosController controller;
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosWidget({
    super.key,
    required this.controller,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.state;

      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state.error != null) {
        return Center(
          child: Text('Erro: ${state.error}'),
        );
      }

      final maxComentarios = state.maxComentarios;
      final canAdd = state.quantComentarios < maxComentarios;

      // Se não tem permissão ou atingiu limite, mostra mensagem centralizada
      if (maxComentarios == 0) {
        return _buildCentralizedNoPermissionWidget(context);
      }

      if (maxComentarios > 0 && !canAdd) {
        return _buildCentralizedLimitReachedWidget(
            context, state.quantComentarios, maxComentarios);
      }

      return Column(
        children: [
          // Campo de busca fixo
          if (state.comentarios.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: SearchCommentsWidget(controller: controller),
            ),
          // Lista de comentários em scroll
          Expanded(
            child: state.comentarios.isEmpty
                ? const EmptyCommentsState()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        CommentsListWidget(
                          controller: controller,
                          comentarios: state.comentariosFiltrados,
                          ferramenta: ferramenta,
                          pkIdentificador: pkIdentificador,
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildCentralizedNoPermissionWidget(BuildContext context) {
    final warningColor = Colors.amber.shade600;
    final warningBackgroundColor = Colors.amber.shade50;
    final warningTextColor = Colors.amber.shade800;

    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(32.0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: warningBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: warningColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Comentários não disponíveis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: warningTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Este recurso esta disponivel apenas para assinantes do app.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: warningTextColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navegarParaPremium(context),
                    icon: const Icon(Icons.diamond),
                    label: const Text('Desbloquear Agora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildCentralizedLimitReachedWidget(
      BuildContext context, int current, int max) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Limite de comentários atingido',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Você já adicionou $current de $max comentários disponíveis.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Para adicionar mais comentários, assine o plano premium.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navegarParaPremium(context),
                      icon: const Icon(Icons.diamond),
                      label: const Text('Assinar Premium'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarParaPremium(BuildContext context) {
    Get.toNamed('/receituagro/premium');
  }
}
