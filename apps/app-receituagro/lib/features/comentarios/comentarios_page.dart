import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/comentarios_design_tokens.dart';
import 'controller/comentarios_controller.dart';
import 'views/widgets/search_comments_widget.dart';
import 'views/widgets/empty_comments_state.dart';
import 'views/widgets/comments_list_widget.dart';
import 'views/widgets/premium_upgrade_widget.dart';
import 'views/widgets/add_comentario_dialog.dart';

class ComentariosPage extends StatelessWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPage({
    super.key,
    this.pkIdentificador,
    this.ferramenta,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ComentariosController>(
      builder: (context, controller, child) {
        // Set filters when the page is built
        controller.setFilters(
          pkIdentificador: pkIdentificador,
          ferramenta: ferramenta,
        );
        
        return const _ComentariosPageContent();
      },
    );
  }
}

class _ComentariosPageContent extends StatelessWidget {
  const _ComentariosPageContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ComentariosDesignTokens.maxPageWidth,
            ),
            child: Column(
              children: [
                _buildModernHeader(context, isDark),
                const Expanded(
                  child: _ComentariosWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Consumer<ComentariosController>(
        builder: (context, controller, _) {
          final state = controller.state;
          final canAdd = state.canAddComentario;
          
          if (state.maxComentarios > 0 && canAdd) {
            return FloatingActionButton(
              onPressed: () => _onAddComentario(context),
              child: const Icon(ComentariosDesignTokens.addIcon),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Consumer<ComentariosController>(
      builder: (context, controller, _) {
        return Container(
          padding: ComentariosDesignTokens.defaultPadding,
          child: Card(
            elevation: ComentariosDesignTokens.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ComentariosDesignTokens.defaultBorderRadius,
              ),
            ),
            child: Padding(
              padding: ComentariosDesignTokens.cardPadding,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ComentariosDesignTokens.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      ComentariosDesignTokens.commentIcon,
                      color: ComentariosDesignTokens.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comentários',
                          style: ComentariosDesignTokens.getTitleStyle(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHeaderSubtitle(controller.state),
                          style: ComentariosDesignTokens.getBodyStyle(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(ComentariosDesignTokens.infoIcon),
                    onPressed: () => _showInfoDialog(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getHeaderSubtitle(state) {
    if (state.isLoading) {
      return ComentariosDesignTokens.loadingMessage;
    }

    final total = state.comentarios.length;
    if (total > 0) {
      return '$total comentários';
    }

    return 'Suas anotações pessoais';
  }

  void _onAddComentario(BuildContext context) {
    final controller = context.read<ComentariosController>();
    showDialog(
      context: context,
      builder: (context) => AddComentarioDialog(
        onSave: (content) => controller.addComentario(content),
      ),
    );
  }


  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre Comentários'),
        content: const Text(
          'Use esta seção para criar anotações pessoais sobre suas experiências '
          'com culturas, pragas e defensivos. Seus comentários ficam salvos '
          'localmente e podem ser filtrados por contexto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

class _ComentariosWidget extends StatelessWidget {
  const _ComentariosWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<ComentariosController>(
      builder: (context, controller, _) {
        final state = controller.state;

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ComentariosDesignTokens.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro: ${state.error}',
                  style: const TextStyle(color: ComentariosDesignTokens.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadComentarios(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final maxComentarios = state.maxComentarios;

        if (state.hasNoPermission) {
          return PremiumUpgradeWidget.noPermission(
            onUpgrade: () => _navigateToUpgrade(context),
          );
        }

        if (state.hasReachedLimit) {
          return PremiumUpgradeWidget.limitReached(
            current: state.quantComentarios,
            max: maxComentarios,
            onUpgrade: () => _navigateToUpgrade(context),
          );
        }

        return Column(
          children: [
            if (state.comentarios.isNotEmpty)
              SearchCommentsWidget(
                controller: controller.searchController,
                onChanged: (_) {}, // Handled by controller listener
                onClear: controller.clearSearch,
              ),
            Expanded(
              child: state.comentarios.isEmpty
                  ? const EmptyCommentsState()
                  : CommentsListWidget(
                      comentarios: state.comentariosFiltrados,
                      editStates: state.editStates,
                      onStartEdit: controller.startEditingComentario,
                      onEdit: controller.updateComentario,
                      onDelete: controller.deleteComentario,
                      onCancelEdit: controller.stopEditingComentario,
                      onContentChanged: controller.updateEditingContent,
                    ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToUpgrade(BuildContext context) {
    // Navigate to subscription/upgrade page
    debugPrint('Navigate to upgrade page');
  }
}