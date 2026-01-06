import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/premium_feature_card.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../subscription/presentation/providers/subscription_notifier.dart';
import 'domain/entities/comentario_entity.dart';
import 'presentation/providers/comentarios_notifier.dart';
import 'widgets/index.dart';

/// Comentários Page - Refatorada com módulos especializados
///
/// Responsabilidade única: Orquestração da página de comentários
///
/// Refatoração:
/// - 927 linhas → ~200 linhas (-78%)
/// - 4 módulos especializados:
///   - comentarios_helpers.dart (formatação e ícones)
///   - comentarios_empty_state_widget.dart (empty state)
///   - comentario_card_widget.dart (card individual)
///   - add_comment_dialog_widget.dart (dialog completo)
class ComentariosPage extends ConsumerWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const ComentariosPage({super.key, this.pkIdentificador, this.ferramenta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ComentariosPageContent(
      pkIdentificador: pkIdentificador,
      ferramenta: ferramenta,
    );
  }
}

class _ComentariosPageContent extends ConsumerStatefulWidget {
  final String? pkIdentificador;
  final String? ferramenta;

  const _ComentariosPageContent({this.pkIdentificador, this.ferramenta});

  @override
  ConsumerState<_ComentariosPageContent> createState() =>
      _ComentariosPageContentState();
}

class _ComentariosPageContentState
    extends ConsumerState<_ComentariosPageContent> {
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_dataInitialized) return;

    final commentNotifier = ref.read(comentariosProvider.notifier);
    await commentNotifier.ensureDataLoaded(
      context: widget.pkIdentificador,
      tool: widget.ferramenta,
    );

    if (mounted) {
      setState(() {
        _dataInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ResponsiveContentWrapper(
            child: Column(
              children: [
                _buildModernHeader(context, isDark),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final comentariosAsync = ref.watch(comentariosProvider);

        return comentariosAsync.when(
          data: (comentariosState) {
            String subtitle;
            if (comentariosState.isLoading) {
              subtitle = 'Carregando comentários...';
            } else {
              final total = comentariosState.totalCount;
              final filtered = comentariosState.filteredComentarios.isNotEmpty
                  ? comentariosState.filteredComentarios.length
                  : comentariosState.comentarios.length;

              if (widget.pkIdentificador != null || widget.ferramenta != null) {
                subtitle = filtered > 0
                    ? '$filtered comentários para este contexto'
                    : 'Nenhum comentário neste contexto';
              } else {
                subtitle = total > 0
                    ? '$total comentários'
                    : 'Suas anotações pessoais';
              }
            }

            return ModernHeaderWidget(
              title: 'Comentários',
              subtitle: subtitle,
              leftIcon: Icons.comment_outlined,
              showBackButton: false,
              showActions: true,
              isDark: isDark,
              rightIcon: Icons.info_outline,
              onRightIconPressed: () => _showInfoDialog(context),
            );
          },
          loading: () => ModernHeaderWidget(
            title: 'Comentários',
            subtitle: 'Carregando...',
            leftIcon: Icons.comment_outlined,
            showBackButton: false,
            showActions: true,
            isDark: isDark,
            rightIcon: Icons.info_outline,
            onRightIconPressed: () => _showInfoDialog(context),
          ),
          error: (_, __) => ModernHeaderWidget(
            title: 'Comentários',
            subtitle: 'Erro ao carregar',
            leftIcon: Icons.comment_outlined,
            showBackButton: false,
            showActions: true,
            isDark: isDark,
            rightIcon: Icons.info_outline,
            onRightIconPressed: () => _showInfoDialog(context),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) {
        final comentariosAsync = ref.watch(comentariosProvider);
        // ✅ Usa subscriptionManagementProvider para verificação correta na web
        final subscriptionAsync = ref.watch(subscriptionManagementProvider);

        return subscriptionAsync.when(
          data: (subscriptionState) {
            final isPremium = subscriptionState.hasActiveSubscription;

            if (!isPremium) {
              return PremiumFeatureCard(
                title: 'Conteúdo Premium',
                description:
                    'Desbloqueie recursos exclusivos e tenha acesso completo a todas as funcionalidades do aplicativo.',
                buttonText: 'Desbloquear Agora',
                useRocketIcon: true,
                onUpgradePressed: () {
                  context.pushNamed('/subscription');
                },
              );
            }

            return comentariosAsync.when(
              data: (comentariosState) {
                if (comentariosState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (comentariosState.errorMessage != null) {
                  return Center(
                    child: Text('Erro: ${comentariosState.errorMessage}'),
                  );
                }

                final comentariosParaMostrar =
                    comentariosState.filteredComentarios.isNotEmpty
                    ? comentariosState.filteredComentarios
                    : comentariosState.comentarios;

                if (comentariosParaMostrar.isEmpty) {
                  return const ComentariosEmptyStateWidget();
                }

                return _buildComentariosList(comentariosParaMostrar);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erro: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => PremiumFeatureCard(
            title: 'Conteúdo Premium',
            description:
                'Desbloqueie recursos exclusivos e tenha acesso completo a todas as funcionalidades do aplicativo.',
            buttonText: 'Desbloquear Agora',
            useRocketIcon: true,
            onUpgradePressed: () {
              context.pushNamed('/subscription');
            },
          ),
        );
      },
    );
  }

  Widget _buildComentariosList(List<ComentarioEntity> comentarios) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: comentarios.length,
      itemBuilder: (context, index) {
        final comentario = comentarios[index];
        return ComentarioCardWidget(
          comentario: comentario,
          onDelete: () => _deleteComentario(context, comentario),
        );
      },
    );
  }

  Widget _buildFAB() {
    return Consumer(
      builder: (context, ref, child) {
        final comentariosAsync = ref.watch(comentariosProvider);
        // ✅ Usa subscriptionManagementProvider para verificação correta na web
        final subscriptionAsync = ref.watch(subscriptionManagementProvider);

        return subscriptionAsync.when(
          data: (subscriptionState) {
            final isPremium = subscriptionState.hasActiveSubscription;

            return FloatingActionButton(
              onPressed: () {
                if (!isPremium) return;

                comentariosAsync.whenData((comentariosState) {
                  if (!comentariosState.isOperating) {
                    _onAddComentario(context);
                  }
                });
              },
              backgroundColor: !isPremium ? Colors.grey : null,
              child: !isPremium
                  ? const Icon(Icons.lock)
                  : const Icon(Icons.add),
            );
          },
          loading: () => const FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.grey,
            child: Icon(Icons.lock),
          ),
          error: (_, __) => const FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.grey,
            child: Icon(Icons.lock),
          ),
        );
      },
    );
  }

  void _onAddComentario(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AddCommentDialogWidget(
        origem: widget.ferramenta ?? 'Comentários',
        itemName: widget.pkIdentificador != null
            ? 'Item ${widget.pkIdentificador}'
            : 'Comentário direto',
        pkIdentificador: widget.pkIdentificador,
        ferramenta: widget.ferramenta,
        onSave: (content) async {
          final comentario = _createComentarioFromContent(content);
          await ref
              .read(comentariosProvider.notifier)
              .addComentario(comentario);
        },
        onCancel: () {},
      ),
    );
  }

  void _deleteComentario(BuildContext context, ComentarioEntity comentario) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Comentário'),
        content: const Text(
          'Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref
                  .read(comentariosProvider.notifier)
                  .deleteComentario(comentario.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
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

  /// Helper method to create ComentarioEntity from content
  ComentarioEntity _createComentarioFromContent(String content) {
    final now = DateTime.now();
    return ComentarioEntity(
      id: 'TEMP_${now.millisecondsSinceEpoch}',
      idReg: 'REG_${now.millisecondsSinceEpoch}',
      titulo: 'Comentário',
      conteudo: content,
      ferramenta: widget.ferramenta ?? 'Comentários',
      pkIdentificador: widget.pkIdentificador ?? '',
      status: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
