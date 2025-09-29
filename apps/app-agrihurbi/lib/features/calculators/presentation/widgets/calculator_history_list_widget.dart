import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';
import '../providers/calculator_provider.dart';

/// Widget para lista do histórico de cálculos
/// 
/// Implementa lista otimizada com ações de histórico
/// Inclui formatação de datas e resultados
class CalculatorHistoryListWidget extends StatelessWidget {
  final List<CalculationHistory> history;
  final ScrollController? scrollController;
  final Function(CalculationHistory) onReapply;
  final Function(CalculationHistory) onDelete;

  const CalculatorHistoryListWidget({
    super.key,
    required history,
    scrollController,
    required onReapply,
    required onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: history.length,
      // Otimizações de performance:
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 400.0,
      itemBuilder: (context, index) {
        final historyItem = history[index];
        return RepaintBoundary(
          child: _buildHistoryCard(context, historyItem),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 4.0),
    );
  }

  Widget _buildHistoryCard(BuildContext context, CalculationHistory historyItem) {
    return DSCard(
      key: ValueKey(historyItem.id),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      onTap: () => onReapply(historyItem),
      child: Row(
        children: [
          // Ícone da calculadora
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.calculate, color: Colors.white),
          ),
          
          const SizedBox(width: 16),
          
          // Informações principais
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historyItem.calculatorName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatHistoryResult(historyItem),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(historyItem.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          // Menu de ações
          PopupMenuButton<String>(
            onSelected: (value) => _handleHistoryAction(context, value, historyItem),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reapply',
                child: Row(
                  children: [
                    Icon(Icons.replay),
                    SizedBox(width: 8),
                    Text('Reaplicar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remover', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleHistoryAction(
    BuildContext context, 
    String action, 
    CalculationHistory historyItem,
  ) {
    switch (action) {
      case 'reapply':
        onReapply(historyItem);
        break;
      case 'delete':
        _showDeleteConfirmation(context, historyItem);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context, 
    CalculationHistory historyItem,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover do Histórico'),
        content: Text(
          'Tem certeza que deseja remover "${historyItem.calculatorName}" do histórico?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(historyItem);
              
              // Mostrar feedback de sucesso
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removido do histórico'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatHistoryResult(CalculationHistory historyItem) {
    final result = historyItem.result;
    if (result.type == ResultType.single && result.values.isNotEmpty) {
      final value = result.values.first;
      return '${value.label}: ${value.value} ${value.unit}';
    } else if (result.type == ResultType.multiple && result.values.isNotEmpty) {
      final primaryValue = result.values.firstWhere(
        (v) => v.isPrimary,
        orElse: () => result.values.first,
      );
      return '${primaryValue.label}: ${primaryValue.value} ${primaryValue.unit}';
    }
    return 'Resultado calculado';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min atrás';
      } else {
        return '${difference.inHours}h atrás';
      }
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}