import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../providers/diagnosticos_by_entity_provider.dart';

/// Widget unificado para exibir diagnósticos por entidade
/// 
/// Pode ser usado para pragas, defensivos ou culturas.
/// Resolve todos os nomes no provider (server-side), não no widget.
/// 
/// Exemplo de uso:
/// ```dart
/// DiagnosticosByEntityWidget(
///   entityType: DiagnosticoEntityType.praga,
///   entityId: 'abc123',
///   entityName: 'Lagarta-da-soja',
/// )
/// ```
class DiagnosticosByEntityWidget extends ConsumerWidget {
  final DiagnosticoEntityType entityType;
  final String entityId;
  final String? entityName;
  final Widget Function(DiagnosticoDisplayItem item)? itemBuilder;
  final VoidCallback? onItemTap;

  const DiagnosticosByEntityWidget({
    super.key,
    required this.entityType,
    required this.entityId,
    this.entityName,
    this.itemBuilder,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = DiagnosticosByEntityParams(
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
    );
    
    final stateAsync = ref.watch(diagnosticosByEntityProvider(params));

    return stateAsync.when(
      data: (state) {
        if (state.isLoading) {
          return const _LoadingWidget();
        }

        if (state.hasError) {
          return _ErrorWidget(
            message: state.errorMessage ?? 'Erro desconhecido',
            onRetry: () => ref.read(diagnosticosByEntityProvider(params).notifier).loadDiagnosticos(),
          );
        }

        if (!state.hasData) {
          return const _EmptyWidget();
        }

        return Column(
          children: [
            // Filtros
            _FilterBar(params: params),
            
            // Lista
            Expanded(
              child: _DiagnosticosList(
                items: state.filteredItems,
                groupedItems: state.groupedItems,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        );
      },
      loading: () => const _LoadingWidget(),
      error: (error, _) => _ErrorWidget(
        message: error.toString(),
        onRetry: () => ref.read(diagnosticosByEntityProvider(params).notifier).loadDiagnosticos(),
      ),
    );
  }
}

/// Barra de filtros
class _FilterBar extends ConsumerWidget {
  final DiagnosticosByEntityParams params;

  const _FilterBar({required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diagnosticosByEntityProvider(params));

    return state.when(
      data: (data) => Padding(
        padding: const EdgeInsets.all(SpacingTokens.sm),
        child: Row(
          children: [
            // Campo de busca
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  ref.read(diagnosticosByEntityProvider(params).notifier)
                      .updateSearchQuery(value);
                },
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            // Dropdown de cultura
            DropdownButton<String>(
              value: data.selectedCultura,
              items: data.culturas.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(diagnosticosByEntityProvider(params).notifier)
                      .updateSelectedCultura(value);
                }
              },
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 56),
      error: (_, __) => const SizedBox(height: 56),
    );
  }
}

/// Lista de diagnósticos agrupados por cultura
class _DiagnosticosList extends StatelessWidget {
  final List<DiagnosticoDisplayItem> items;
  final Map<String, List<DiagnosticoDisplayItem>> groupedItems;
  final Widget Function(DiagnosticoDisplayItem item)? itemBuilder;

  const _DiagnosticosList({
    required this.items,
    required this.groupedItems,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyWidget();
    }

    // Cria lista flat com headers e itens
    final flatList = <_ListItem>[];
    final culturasOrdenadas = groupedItems.keys.toList()..sort();

    for (final cultura in culturasOrdenadas) {
      final diagnosticos = groupedItems[cultura]!;
      
      // Header da cultura
      flatList.add(_ListItem.header(cultura, diagnosticos.length));
      
      // Itens da cultura
      for (final item in diagnosticos) {
        flatList.add(_ListItem.item(item));
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: SpacingTokens.bottomNavSpace),
      itemCount: flatList.length,
      separatorBuilder: (context, index) {
        final current = flatList[index];
        final next = index + 1 < flatList.length ? flatList[index + 1] : null;

        if (current.isHeader) {
          return const SizedBox(height: 4);
        }
        if (next != null && next.isHeader) {
          return const SizedBox(height: SpacingTokens.lg);
        }
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        final listItem = flatList[index];

        if (listItem.isHeader) {
          return _CultureHeader(
            cultura: listItem.headerTitle!,
            count: listItem.headerCount!,
          );
        }

        final item = listItem.diagnostico!;
        return itemBuilder?.call(item) ?? _DefaultItemWidget(item: item);
      },
    );
  }
}

/// Item da lista (header ou diagnóstico)
class _ListItem {
  final bool isHeader;
  final String? headerTitle;
  final int? headerCount;
  final DiagnosticoDisplayItem? diagnostico;

  _ListItem._({
    required this.isHeader,
    this.headerTitle,
    this.headerCount,
    this.diagnostico,
  });

  factory _ListItem.header(String title, int count) {
    return _ListItem._(isHeader: true, headerTitle: title, headerCount: count);
  }

  factory _ListItem.item(DiagnosticoDisplayItem diagnostico) {
    return _ListItem._(isHeader: false, diagnostico: diagnostico);
  }
}

/// Header de cultura
class _CultureHeader extends StatelessWidget {
  final String cultura;
  final int count;

  const _CultureHeader({required this.cultura, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text(
            cultura,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de item padrão
class _DefaultItemWidget extends StatelessWidget {
  final DiagnosticoDisplayItem item;

  const _DefaultItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        item.nomeDefensivo,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.ingredienteAtivo),
          Text('Dosagem: ${item.dosagem}'),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

/// Widget de loading
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.xxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Widget de erro
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorWidget({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'Erro ao carregar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: SpacingTokens.lg),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de estado vazio
class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'Nenhum diagnóstico encontrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Não há diagnósticos disponíveis para esta entidade',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
