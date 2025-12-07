import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing_tokens.dart';
import '../../../diagnosticos/presentation/providers/diagnosticos_by_entity_provider.dart';
import '../providers/diagnosticos_praga_notifier.dart';
import 'diagnostico_dialog_widget.dart';

/// Widget principal para exibir diagnósticos de uma praga
/// 
/// Utiliza o provider unificado `DiagnosticosByEntityProvider` que resolve
/// todos os nomes no backend, eliminando FutureBuilders no widget.
/// 
/// **Vantagens sobre a versão anterior:**
/// - Nomes resolvidos no provider (não no widget)
/// - Sem FutureBuilder aninhados
/// - Estado consistente e tipado
/// - Filtros integrados no provider
/// - Melhor performance e manutenibilidade
class DiagnosticosPragaUnifiedWidget extends ConsumerWidget {
  final String pragaId;
  final String pragaName;

  const DiagnosticosPragaUnifiedWidget({
    super.key,
    required this.pragaId,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = DiagnosticosByEntityParams(
      entityType: DiagnosticoEntityType.praga,
      entityId: pragaId,
      entityName: pragaName,
    );

    final stateAsync = ref.watch(diagnosticosByEntityProvider(params));

    return RepaintBoundary(
      child: stateAsync.when(
        data: (state) {
          if (state.isLoading) {
            return const _LoadingWidget();
          }

          if (state.hasError) {
            return _ErrorWidget(
              message: state.errorMessage ?? 'Erro desconhecido',
              onRetry: () => ref
                  .read(diagnosticosByEntityProvider(params).notifier)
                  .loadDiagnosticos(),
            );
          }

          return Column(
            children: [
              // Filtros
              _FilterBar(params: params, state: state),

              // Lista
              Expanded(
                child: state.filteredItems.isEmpty
                    ? _EmptyWidget(
                        hasFilters: state.searchQuery.isNotEmpty ||
                            state.selectedCultura != 'Todas',
                        onClearFilters: () => ref
                            .read(diagnosticosByEntityProvider(params).notifier)
                            .clearFilters(),
                      )
                    : _DiagnosticosList(
                        params: params,
                        groupedItems: state.groupedItems,
                        pragaName: pragaName,
                      ),
              ),
            ],
          );
        },
        loading: () => const _LoadingWidget(),
        error: (error, _) => _ErrorWidget(
          message: error.toString(),
          onRetry: () => ref
              .read(diagnosticosByEntityProvider(params).notifier)
              .loadDiagnosticos(),
        ),
      ),
    );
  }
}

/// Barra de filtros
class _FilterBar extends ConsumerWidget {
  final DiagnosticosByEntityParams params;
  final DiagnosticosByEntityState state;

  const _FilterBar({required this.params, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          // Campo de busca
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar defensivo...',
                  prefixIcon: const Icon(Icons.search, size: 20),
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
                  ref
                      .read(diagnosticosByEntityProvider(params).notifier)
                      .updateSearchQuery(value);
                },
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          // Dropdown de cultura
          Container(
            constraints: const BoxConstraints(maxWidth: 150),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.selectedCultura,
                isExpanded: true,
                icon: const Icon(Icons.filter_list),
                items: state.culturas
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(diagnosticosByEntityProvider(params).notifier)
                        .updateSelectedCultura(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de diagnósticos agrupados por cultura
class _DiagnosticosList extends StatelessWidget {
  final DiagnosticosByEntityParams params;
  final Map<String, List<DiagnosticoDisplayItem>> groupedItems;
  final String pragaName;

  const _DiagnosticosList({
    required this.params,
    required this.groupedItems,
    required this.pragaName,
  });

  @override
  Widget build(BuildContext context) {
    // Cria lista flat com headers e itens
    final flatList = <_ListItem>[];
    final culturasOrdenadas = groupedItems.keys.toList()..sort();

    for (final cultura in culturasOrdenadas) {
      final diagnosticos = groupedItems[cultura]!;

      // Ordena por nome do defensivo
      diagnosticos.sort((a, b) =>
          a.nomeDefensivo.toLowerCase().compareTo(b.nomeDefensivo.toLowerCase()));

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
          return const SizedBox(height: 2);
        }
        if (next != null && next.isHeader) {
          return const SizedBox(height: SpacingTokens.lg);
        }
        return const Divider(height: 1, thickness: 1);
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
        return _DiagnosticoItem(
          item: item,
          pragaName: pragaName,
        );
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
          Expanded(
            child: Text(
              cultura,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
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

/// Item de diagnóstico com visual moderno
class _DiagnosticoItem extends StatelessWidget {
  final DiagnosticoDisplayItem item;
  final String pragaName;

  const _DiagnosticoItem({required this.item, required this.pragaName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _showDiagnosticoDialog(context, item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Ícone de defensivo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sanitizer_outlined,
                color: theme.colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nomeDefensivo,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.ingredienteAtivo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.dosagem,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Seta
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagnosticoDialog(BuildContext context, DiagnosticoDisplayItem item) {
    // Converte para DiagnosticoModel para compatibilidade com dialog existente
    final model = DiagnosticoModel(
      id: item.id,
      nome: item.nomeDefensivo,
      cultura: item.nomeCultura,
      ingredienteAtivo: item.ingredienteAtivo,
      dosagem: item.dosagem,
      grupo: item.nomePraga,
      aplicacaoTerrestre: item.aplicacaoTerrestre,
      aplicacaoAerea: item.aplicacaoAerea,
      intervaloSeguranca: item.intervaloSeguranca,
    );
    DiagnosticoDialogWidget.show(context, model, pragaName);
  }
}

/// Widget de loading
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar diagnósticos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
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
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const _EmptyWidget({
    this.hasFilters = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.bug_report_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'Nenhum diagnóstico encontrado'
                  : 'Nenhum diagnóstico disponível',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Tente ajustar os filtros de pesquisa'
                  : 'Esta praga ainda não possui diagnósticos cadastrados',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasFilters && onClearFilters != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Limpar Filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
