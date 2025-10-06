import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/performance_benchmark.dart';
import '../../domain/entities/calculator_entity.dart';
import '../providers/calculator_provider.dart';
import 'calculator_card_widget.dart';
import 'calculator_empty_state_widget.dart';

/// Widget para exibir resultados de busca de calculadoras
///
/// Implementa lista de resultados com contagem e performance stats
/// Inclui feedback visual e ações de navegação
class CalculatorSearchResultsWidget extends StatelessWidget {
  final List<CalculatorEntity> searchResults;
  final bool isSearching;
  final bool showCategory;
  final ScrollController? scrollController;
  final VoidCallback? onClearFilters;
  final int searchCallCount;

  const CalculatorSearchResultsWidget({
    super.key,
    required this.searchResults,
    required this.isSearching,
    this.showCategory = true,
    this.scrollController,
    this.onClearFilters,
    this.searchCallCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return _buildLoadingState();
    }

    if (searchResults.isEmpty) {
      return CalculatorEmptyStateWidget(
        type: CalculatorEmptyStateType.noSearchResults,
        onAction: onClearFilters,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho dos resultados
        _buildResultsHeader(context),

        // Stats de performance (apenas em debug)
        if (kDebugMode) _buildPerformanceStats(context),

        // Lista de resultados
        Expanded(child: _buildResultsList(context)),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Buscando calculadoras...'),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '${searchResults.length} ${searchResults.length == 1 ? "calculadora encontrada" : "calculadoras encontradas"}',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPerformanceStats(BuildContext context) {
    final stats = PerformanceBenchmark.getOperationStats('search_otimizada');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Performance Stats',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Buscas realizadas: $searchCallCount | '
            'Tempo médio: ${stats.averageDuration.toStringAsFixed(1)}ms | '
            'Resultados encontrados: ${searchResults.length}',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: searchResults.length,
      // Otimizações de performance
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 500.0,
      itemBuilder: (context, index) {
        final calculator = searchResults[index];
        return RepaintBoundary(
          key: ValueKey(calculator.id),
          child: Consumer(
            builder: (context, ref, child) {
              final provider = ref.watch(calculatorProvider);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CalculatorCardWidget(
                  calculator: calculator,
                  isFavorite: provider.isCalculatorFavorite(calculator.id),
                  onTap: () => _navigateToCalculator(context, calculator.id),
                  onFavoriteToggle:
                      () => ref
                          .read(calculatorProvider)
                          .toggleFavorite(calculator.id),
                  showCategory: showCategory,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToCalculator(BuildContext context, String calculatorId) {
    context.push('/home/calculators/detail/$calculatorId');
  }
}
