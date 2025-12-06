import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing_tokens.dart';
import '../../../../diagnosticos/presentation/providers/diagnosticos_by_entity_provider.dart';
import 'diagnosticos_defensivos_components.dart';

/// Widget principal para exibir diagnósticos de um defensivo
/// 
/// Utiliza o provider unificado `DiagnosticosByEntityProvider` que resolve
/// todos os nomes no backend, eliminando FutureBuilders no widget.
/// 
/// **Vantagens sobre a versão anterior:**
/// - Nomes resolvidos no provider (não no widget)
/// - Sem FutureBuilder aninhados (eram 3 níveis!)
/// - Estado consistente e tipado
/// - Filtros integrados no provider
/// - Melhor performance e manutenibilidade
/// - ~200 linhas vs ~400 linhas da versão anterior
class DiagnosticosDefensivoUnifiedWidget extends ConsumerWidget {
  final String defensivoId;
  final String defensivoName;

  const DiagnosticosDefensivoUnifiedWidget({
    super.key,
    required this.defensivoId,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = DiagnosticosByEntityParams(
      entityType: DiagnosticoEntityType.defensivo,
      entityId: defensivoId,
      entityName: defensivoName,
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
              DiagnosticoDefensivoFilterWidget(
                availableCulturas: state.culturas
                    .where((c) => c != 'Todas')
                    .toList(),
              ),

              // Lista
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: SpacingTokens.xs,
                    bottom: SpacingTokens.bottomNavSpace,
                  ),
                  child: state.filteredItems.isEmpty
                      ? _EmptyWidget(
                          hasFilters: state.searchQuery.isNotEmpty ||
                              state.selectedCultura != 'Todas',
                          onClearFilters: () => ref
                              .read(diagnosticosByEntityProvider(params).notifier)
                              .clearFilters(),
                        )
                      : _DiagnosticosList(
                          ref: ref,
                          params: params,
                          groupedItems: state.groupedItems,
                          defensivoName: defensivoName,
                        ),
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

/// Lista de diagnósticos agrupados por cultura
class _DiagnosticosList extends StatelessWidget {
  final WidgetRef ref;
  final DiagnosticosByEntityParams params;
  final Map<String, List<DiagnosticoDisplayItem>> groupedItems;
  final String defensivoName;

  const _DiagnosticosList({
    required this.ref,
    required this.params,
    required this.groupedItems,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    // Cria lista flat com headers e itens
    final flatList = <_ListItem>[];
    final culturasOrdenadas = groupedItems.keys.toList()..sort();

    for (final cultura in culturasOrdenadas) {
      final diagnosticos = groupedItems[cultura]!;

      // Ordena por nome da praga
      diagnosticos.sort((a, b) =>
          a.nomePraga.toLowerCase().compareTo(b.nomePraga.toLowerCase()));

      // Header da cultura
      flatList.add(_ListItem.header(cultura, diagnosticos.length, diagnosticos));

      // Itens da cultura
      for (final item in diagnosticos) {
        flatList.add(_ListItem.item(item));
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flatList.length,
      separatorBuilder: (context, index) {
        final current = flatList[index];
        final next = index + 1 < flatList.length ? flatList[index + 1] : null;

        if (current.isHeader) {
          return const SizedBox(height: 2);
        }
        if (next != null && next.isHeader) {
          return const SizedBox(height: 2);
        }
        return const Divider(height: 1, thickness: 1);
      },
      itemBuilder: (context, index) {
        final listItem = flatList[index];

        if (listItem.isHeader) {
          return DiagnosticoDefensivoCultureSectionWidget(
            cultura: listItem.headerTitle!,
            diagnosticCount: listItem.headerCount!,
            diagnosticos: listItem.diagnosticos!
                .map((d) => _toDefensivoMap(d))
                .toList(),
          );
        }

        final item = listItem.diagnostico!;
        return DiagnosticoDefensivoListItemWidget(
          diagnostico: _toDefensivoMap(item),
          onTap: () => _showDiagnosticoDialog(context, item),
          isDense: true,
          hasElevation: false,
        );
      },
    );
  }

  /// Converte DiagnosticoDisplayItem para Map usado pelos widgets existentes
  Map<String, dynamic> _toDefensivoMap(DiagnosticoDisplayItem item) {
    return {
      'id': item.id,
      'nomePraga': item.nomePraga,
      'nomeCultura': item.nomeCultura,
      'nomeDefensivo': item.nomeDefensivo,
      'ingredienteAtivo': item.ingredienteAtivo,
      'dosagem': item.dosagem,
      'aplicacaoTerrestre': item.aplicacaoTerrestre,
      'aplicacaoAerea': item.aplicacaoAerea,
      'intervaloSeguranca': item.intervaloSeguranca,
    };
  }

  void _showDiagnosticoDialog(BuildContext context, DiagnosticoDisplayItem item) {
    DiagnosticoDefensivoDialogWidget.show(
      context,
      ref,
      _toDefensivoMap(item),
      defensivoName,
    );
  }
}

/// Item da lista (header ou diagnóstico)
class _ListItem {
  final bool isHeader;
  final String? headerTitle;
  final int? headerCount;
  final List<DiagnosticoDisplayItem>? diagnosticos;
  final DiagnosticoDisplayItem? diagnostico;

  _ListItem._({
    required this.isHeader,
    this.headerTitle,
    this.headerCount,
    this.diagnosticos,
    this.diagnostico,
  });

  factory _ListItem.header(
    String title,
    int count,
    List<DiagnosticoDisplayItem> diagnosticos,
  ) {
    return _ListItem._(
      isHeader: true,
      headerTitle: title,
      headerCount: count,
      diagnosticos: diagnosticos,
    );
  }

  factory _ListItem.item(DiagnosticoDisplayItem diagnostico) {
    return _ListItem._(isHeader: false, diagnostico: diagnostico);
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
              hasFilters ? Icons.search_off : Icons.science_outlined,
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
                  : 'Este defensivo ainda não possui diagnósticos cadastrados',
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
