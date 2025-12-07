import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing_tokens.dart';
import '../../../../diagnosticos/presentation/providers/diagnosticos_by_entity_provider.dart';
import '../../providers/detalhe_defensivo_notifier.dart';
import 'diagnosticos_defensivos_components.dart';

/// Widget principal responsável por exibir diagnósticos relacionados ao defensivo
///
/// **VERSÃO REFATORADA** - Usa o provider unificado `diagnosticosByEntityProvider`
/// que resolve todos os nomes no backend, eliminando FutureBuilders.
///
/// Responsabilidade única: orquestrar componentes para exibir diagnósticos
/// - Filtros de pesquisa e cultura
/// - Lista agrupada de diagnósticos
/// - Estados de loading, erro e vazio
/// - Modal de detalhes do diagnóstico
///
/// **Arquitetura Decomposta:**
/// - `DiagnosticoDefensivoFilterWidget`: Filtros de pesquisa
/// - `DiagnosticoDefensivoListItemWidget`: Itens da lista
/// - `DiagnosticoDefensivoDialogWidget`: Modal de detalhes
///
/// **Performance Otimizada:**
/// - RepaintBoundary para evitar rebuilds desnecessários
/// - Nomes resolvidos no provider (não no widget)
/// - Sem FutureBuilder aninhados
/// - Estado consistente e tipado
class DiagnosticosTabWidget extends ConsumerWidget {
  final String defensivoName;

  const DiagnosticosTabWidget({super.key, required this.defensivoName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtém o ID do defensivo do provider de detalhes
    final detalheState = ref.watch(detalheDefensivoProvider);
    
    return detalheState.when(
      data: (data) {
        final defensivoId = data.defensivoData?.idDefensivo;
        
        if (defensivoId == null || defensivoId.isEmpty) {
          return _buildEmptyState(
            context,
            hasFilters: false,
            message: 'Carregando dados do defensivo...',
          );
        }
        
        return _DiagnosticosContent(
          defensivoId: defensivoId,
          defensivoName: defensivoName,
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        return _buildErrorState(
          context,
          error.toString(),
          () => ref.invalidate(detalheDefensivoProvider),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool hasFilters, String? message}) {
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
              message ?? (hasFilters
                  ? 'Nenhum diagnóstico encontrado'
                  : 'Nenhum diagnóstico disponível'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, VoidCallback onRetry) {
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget interno que gerencia o estado dos diagnósticos
class _DiagnosticosContent extends ConsumerWidget {
  final String defensivoId;
  final String defensivoName;

  const _DiagnosticosContent({
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return _buildErrorWidget(
              context,
              state.errorMessage ?? 'Erro desconhecido',
              () => ref
                  .read(diagnosticosByEntityProvider(params).notifier)
                  .loadDiagnosticos(),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtros
              DiagnosticoDefensivoFilterWidget(
                params: params,
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
                      ? _buildEmptyWidget(
                          context,
                          hasFilters: state.searchQuery.isNotEmpty ||
                              state.selectedCultura != 'Todas',
                          onClearFilters: () => ref
                              .read(diagnosticosByEntityProvider(params).notifier)
                              .clearFilters(),
                        )
                      : _DiagnosticosList(
                          params: params,
                          groupedItems: state.groupedItems,
                          defensivoName: defensivoName,
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorWidget(
          context,
          error.toString(),
          () => ref
              .read(diagnosticosByEntityProvider(params).notifier)
              .loadDiagnosticos(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message, VoidCallback onRetry) {
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(
    BuildContext context, {
    required bool hasFilters,
    VoidCallback? onClearFilters,
  }) {
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

/// Lista de diagnósticos agrupados por cultura
class _DiagnosticosList extends ConsumerWidget {
  final DiagnosticosByEntityParams params;
  final Map<String, List<DiagnosticoDisplayItem>> groupedItems;
  final String defensivoName;

  const _DiagnosticosList({
    required this.params,
    required this.groupedItems,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cria lista flat com headers e itens
    final flatList = <_ListItem>[];
    final culturasOrdenadas = groupedItems.keys.toList()..sort();

    for (final cultura in culturasOrdenadas) {
      final diagnosticos = List<DiagnosticoDisplayItem>.from(groupedItems[cultura]!);

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
          onTap: () => _showDiagnosticoDialog(context, ref, item),
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
      'idPraga': item.entity.idPraga,
      'idCultura': item.entity.idCultura,
      'idDefensivo': item.entity.idDefensivo,
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

  void _showDiagnosticoDialog(BuildContext context, WidgetRef ref, DiagnosticoDisplayItem item) {
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
