import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/calculator_entity.dart';
import '../providers/calculator_coordinator_provider.dart';
import 'calculator_card_widget.dart';

/// Widget otimizado para lista de calculadoras
///
/// Implementa lista virtualizada com performance otimizada
/// Inclui RepaintBoundaries e cache adequado
class CalculatorListWidget extends StatelessWidget {
  final List<CalculatorEntity> calculators;
  final ScrollController? scrollController;
  final bool showCategory;
  final VoidCallback? onRefresh;

  const CalculatorListWidget({
    super.key,
    required this.calculators,
    this.scrollController,
    this.showCategory = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (calculators.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
      },
      child: _buildOptimizedList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma calculadora encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente ajustar os filtros de busca\nou aguarde novas calculadoras',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedList() {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: calculators.length,
      addAutomaticKeepAlives: false, // Reduce memory usage
      addRepaintBoundaries: false, // Reduce painting overhead
      cacheExtent: 500.0, // Cache 500px de conteúdo off-screen
      itemBuilder: (context, index) {
        final calculator = calculators[index];
        return RepaintBoundary(
          child: Consumer(
            builder: (context, ref, child) {
              final coordinator =
                  ref.read(calculatorCoordinatorProvider.notifier);
              return CalculatorCardWidget(
                calculator: calculator,
                isFavorite: coordinator.isCalculatorFavorite(calculator.id),
                onTap: () => _navigateToCalculator(context, calculator.id),
                onFavoriteToggle: () =>
                    coordinator.toggleCurrentCalculatorFavorite(),
                key: ValueKey(calculator.id), // Chave estável para otimização
                showCategory: showCategory,
              );
            },
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 8.0);
      },
    );
  }

  void _navigateToCalculator(BuildContext context, String calculatorId) {
    context.push('/home/calculators/detail/$calculatorId');
  }
}
