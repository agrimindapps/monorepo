// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../models/pluviometros_models.dart';

/// Widget otimizado para lista de pluviômetros com performance melhorada
class PerformanceOptimizedList extends StatefulWidget {
  final List<Pluviometro> pluviometros;
  final void Function(String, Pluviometro) onMenuAction;
  final VoidCallback? onRefresh;
  final bool isLoading;
  final String? errorMessage;
  final ScrollController? scrollController;
  final double itemHeight;
  final EdgeInsets padding;

  const PerformanceOptimizedList({
    super.key,
    required this.pluviometros,
    required this.onMenuAction,
    this.onRefresh,
    this.isLoading = false,
    this.errorMessage,
    this.scrollController,
    this.itemHeight = 120.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<PerformanceOptimizedList> createState() =>
      _PerformanceOptimizedListState();
}

class _PerformanceOptimizedListState extends State<PerformanceOptimizedList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.isLoading && widget.pluviometros.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.errorMessage != null) {
      return _buildErrorWidget();
    }

    if (widget.pluviometros.isEmpty) {
      return _buildEmptyWidget();
    }

    Widget child = ListView.builder(
      controller: widget.scrollController,
      padding: widget.padding,
      itemCount: widget.pluviometros.length + (widget.isLoading ? 1 : 0),
      itemExtent: widget.itemHeight, // Altura fixa para melhor performance
      itemBuilder: (context, index) {
        if (index >= widget.pluviometros.length) {
          // Indicador de loading no final da lista
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final pluviometro = widget.pluviometros[index];

        return RepaintBoundary(
          key: ValueKey(pluviometro.id),
          child: OptimizedPluviometroCard(
            pluviometro: pluviometro,
            onMenuAction: widget.onMenuAction,
            index: index,
          ),
        );
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh!();
        },
        child: child,
      );
    }

    return child;
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: ShadcnStyle.titleStyle.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.errorMessage ?? 'Erro desconhecido',
            style: ShadcnStyle.inputStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onRefresh,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum pluviômetro encontrado',
            style: ShadcnStyle.titleStyle.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou adicionar novos pluviômetros',
            style: ShadcnStyle.inputStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card otimizado para pluviômetro
class OptimizedPluviometroCard extends StatefulWidget {
  final Pluviometro pluviometro;
  final void Function(String, Pluviometro) onMenuAction;
  final int index;

  const OptimizedPluviometroCard({
    super.key,
    required this.pluviometro,
    required this.onMenuAction,
    required this.index,
  });

  @override
  State<OptimizedPluviometroCard> createState() =>
      _OptimizedPluviometroCardState();
}

class _OptimizedPluviometroCardState extends State<OptimizedPluviometroCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => widget.onMenuAction('details', widget.pluviometro),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone do pluviômetro
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ShadcnStyle.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: ShadcnStyle.primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Descrição
                    Text(
                      widget.pluviometro.descricao,
                      style: ShadcnStyle.titleStyle.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Quantidade
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.pluviometro.quantidade}mm',
                          style: ShadcnStyle.inputStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Informações extras
                    Row(
                      children: [
                        if (widget.pluviometro.fkGrupo != null &&
                            widget.pluviometro.fkGrupo!.isNotEmpty) ...[
                          Icon(
                            Icons.group,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.pluviometro.fkGrupo!,
                            style: ShadcnStyle.inputStyle.copyWith(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (_hasCoordinates()) ...[
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Localizado',
                            style: ShadcnStyle.inputStyle.copyWith(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.location_off,
                            size: 14,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sem localização',
                            style: ShadcnStyle.inputStyle.copyWith(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Indicador de quantidade
              _buildQuantityIndicator(),

              const SizedBox(width: 12),

              // Menu de ações
              _buildActionMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityIndicator() {
    final quantidade = widget.pluviometro.getQuantidadeAsDouble();
    Color color;
    IconData icon;

    if (quantidade >= 50) {
      color = Colors.red;
      icon = Icons.trending_up;
    } else if (quantidade >= 20) {
      color = Colors.orange;
      icon = Icons.trending_flat;
    } else if (quantidade >= 10) {
      color = Colors.blue;
      icon = Icons.trending_down;
    } else {
      color = Colors.grey;
      icon = Icons.remove;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) => widget.onMenuAction(value, widget.pluviometro),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Text('Detalhes'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  bool _hasCoordinates() {
    return widget.pluviometro.latitude != null &&
        widget.pluviometro.latitude!.isNotEmpty &&
        widget.pluviometro.longitude != null &&
        widget.pluviometro.longitude!.isNotEmpty;
  }
}

/// Widget para paginação
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final void Function(int) onPageChanged;
  final void Function(int) onItemsPerPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informações da página
          Text(
            'Página $currentPage de $totalPages ($totalItems itens)',
            style: ShadcnStyle.inputStyle,
          ),

          // Controles de paginação
          Row(
            children: [
              // Itens por página
              DropdownButton<int>(
                value: itemsPerPage,
                items: const [10, 20, 50, 100].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value por página'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onItemsPerPageChanged(value);
                  }
                },
              ),

              const SizedBox(width: 16),

              // Navegação
              IconButton(
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),

              // Páginas
              ...List.generate(
                totalPages > 7 ? 7 : totalPages,
                (index) {
                  int pageNumber;
                  if (totalPages <= 7) {
                    pageNumber = index + 1;
                  } else {
                    if (currentPage <= 4) {
                      pageNumber = index + 1;
                    } else if (currentPage >= totalPages - 3) {
                      pageNumber = totalPages - 6 + index;
                    } else {
                      pageNumber = currentPage - 3 + index;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: pageNumber == currentPage
                        ? Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: ShadcnStyle.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '$pageNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () => onPageChanged(pageNumber),
                            child: Text('$pageNumber'),
                          ),
                  );
                },
              ),

              IconButton(
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para controle de densidade da lista
class ListDensityControl extends StatelessWidget {
  final ListDensity density;
  final void Function(ListDensity) onDensityChanged;

  const ListDensityControl({
    super.key,
    required this.density,
    required this.onDensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Densidade:',
          style: ShadcnStyle.inputStyle,
        ),
        const SizedBox(width: 8),
        SegmentedButton<ListDensity>(
          segments: const [
            ButtonSegment(
              value: ListDensity.compact,
              label: Text('Compacta'),
              icon: Icon(Icons.view_stream, size: 16),
            ),
            ButtonSegment(
              value: ListDensity.comfortable,
              label: Text('Confortável'),
              icon: Icon(Icons.view_list, size: 16),
            ),
            ButtonSegment(
              value: ListDensity.spacious,
              label: Text('Espaçosa'),
              icon: Icon(Icons.view_module, size: 16),
            ),
          ],
          selected: {density},
          onSelectionChanged: (set) {
            if (set.isNotEmpty) {
              onDensityChanged(set.first);
            }
          },
        ),
      ],
    );
  }
}

/// Enum para densidade da lista
enum ListDensity {
  compact,
  comfortable,
  spacious,
}

/// Extensão para converter densidade em altura
extension ListDensityExtension on ListDensity {
  double get itemHeight {
    switch (this) {
      case ListDensity.compact:
        return 80.0;
      case ListDensity.comfortable:
        return 120.0;
      case ListDensity.spacious:
        return 160.0;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case ListDensity.compact:
        return const EdgeInsets.all(8.0);
      case ListDensity.comfortable:
        return const EdgeInsets.all(16.0);
      case ListDensity.spacious:
        return const EdgeInsets.all(24.0);
    }
  }
}
