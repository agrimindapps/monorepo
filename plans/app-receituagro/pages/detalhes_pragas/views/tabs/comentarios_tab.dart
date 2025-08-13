// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../comentarios/controller/comentarios_controller.dart';
import '../../../comentarios/views/widgets/comentarios_card.dart';
import '../../controller/detalhes_pragas_controller.dart';

class ComentariosTab extends StatelessWidget {
  final DetalhesPragasController controller;

  const ComentariosTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.pragaUnica == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final pragaData = controller.pragaUnica!;
      final pkIdentificador = pragaData.idReg;
      final ferramenta = 'Pragas - ${pragaData.nomeComum}';

      // Configurar filtros do ComentariosController
      final comentariosController = Get.find<ComentariosController>();

      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        comentariosController.setFilters(
          pkIdentificador: pkIdentificador,
          ferramenta: ferramenta,
        );
      });

      return _ComentariosContent(
        comentariosController: comentariosController,
        pkIdentificador: pkIdentificador,
        ferramenta: ferramenta,
      );
    });
  }
}

class _ComentariosContent extends StatefulWidget {
  final ComentariosController comentariosController;
  final String pkIdentificador;
  final String ferramenta;

  const _ComentariosContent({
    required this.comentariosController,
    required this.pkIdentificador,
    required this.ferramenta,
  });

  @override
  State<_ComentariosContent> createState() => _ComentariosContentState();
}

class _ComentariosContentState extends State<_ComentariosContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão para adicionar comentário
          Obx(() {
            final comentariosController = widget.comentariosController;
            final canAdd = comentariosController.state.quantComentarios <
                comentariosController.state.maxComentarios;
            final maxComentarios = comentariosController.state.maxComentarios;

            if (maxComentarios == 0) {
              return _buildNoPermissionWidget(context);
            }

            return Column(
              children: [
                if (!canAdd)
                  _buildLimitReachedWidget(
                      context,
                      comentariosController.state.quantComentarios,
                      maxComentarios),
              ],
            );
          }),

          // Lista de comentários
          Obx(() {
            final comentarios =
                widget.comentariosController.state.comentariosFiltrados;

            if (widget.comentariosController.state.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (comentarios.isEmpty) {
              final maxComentarios =
                  widget.comentariosController.state.maxComentarios;

              // Só mostra "Nenhum comentário ainda" se o usuário tem permissão para adicionar
              if (maxComentarios > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text('Nenhum comentário ainda',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione o primeiro comentário sobre esta praga',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Se não tem permissão e não tem comentários, não mostra nada
                return const SizedBox.shrink();
              }
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comentarios.length,
              itemBuilder: (context, index) {
                final comentario = comentarios[index];
                return ComentariosCard(
                  comentario: comentario,
                  ferramenta: widget.ferramenta,
                  pkIdentificador: widget.pkIdentificador,
                  controller: widget.comentariosController,
                  onEdit: widget.comentariosController.onCardEdit,
                  onDelete: () =>
                      widget.comentariosController.onCardDelete(comentario),
                  onCancel: widget.comentariosController.onCardCancel,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoPermissionWidget(BuildContext context) {
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
      ),
    );
  }

  Widget _buildLimitReachedWidget(BuildContext context, int current, int max) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Limite de comentários atingido',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Você já adicionou $current de $max comentários disponíveis.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Para adicionar mais comentários, assine o plano premium.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 16),
          // Botão para assistir publicidade
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navegarParaPremium(context),
              icon: const Icon(Icons.diamond),
              label: const Text('Assinar Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaPremium(BuildContext context) {
    Get.toNamed('/receituagro/premium');
  }
}
