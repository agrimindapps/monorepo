import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/body_condition_provider.dart';
import '../../domain/entities/body_condition_output.dart';

/// Painel de histórico dos cálculos de condição corporal
class BodyConditionHistoryPanel extends ConsumerWidget {
  const BodyConditionHistoryPanel({
    super.key,
    required this.history,
  });

  final List<BodyConditionOutput> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(bodyConditionHistoryStatsProvider);
    
    return Column(
      children: [
        // Estatísticas do histórico
        if (history.isNotEmpty) _buildStatisticsCard(stats),
        
        // Lista do histórico
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final result = history[history.length - 1 - index]; // Mais recente primeiro
              final position = history.length - index;
              
              return _buildHistoryItem(context, ref, result, position, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Estatísticas do Histórico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total de Avaliações',
                    '${stats['count']}',
                    Icons.assignment,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Score Médio',
                    stats['averageScore'].toStringAsFixed(1),
                    Icons.trending_neutral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '% Peso Ideal',
                    '${stats['idealPercentage'].toStringAsFixed(0)}%',
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tendência',
                    _getTrendText(stats['trend']),
                    _getTrendIcon(stats['trend']),
                    color: _getTrendColor(stats['trend']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getTrendText(double trend) {
    if (trend > 0) return '+${trend.toStringAsFixed(1)}';
    if (trend < 0) return trend.toStringAsFixed(1);
    return 'Estável';
  }

  IconData _getTrendIcon(double trend) {
    if (trend > 0) return Icons.trending_up;
    if (trend < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getTrendColor(double trend) {
    if (trend > 0) return Colors.orange;
    if (trend < 0) return Colors.red;
    return Colors.grey;
  }

  Widget _buildHistoryItem(
    BuildContext context, 
    WidgetRef ref, 
    BodyConditionOutput result, 
    int position, 
    int index
  ) {
    final dateFormatter = DateFormat('dd/MM/yyyy - HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(result.statusColor.substring(1), radix: 16) + 0xFF000000
          ).withOpacity(0.2),
          child: Text(
            '${result.bcsScore}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(
                int.parse(result.statusColor.substring(1), radix: 16) + 0xFF000000
              ),
            ),
          ),
        ),
        title: Text(
          'BCS ${result.bcsScore}/9 - ${result.classification.displayName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormatter.format(result.calculatedAt ?? DateTime.now())),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.monitor_weight,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  result.results
                      .firstWhere((r) => r.label == 'Peso Atual')
                      .formattedValue,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(
                  _getUrgencyIcon(result.actionUrgency),
                  size: 16,
                  color: _getUrgencyColor(result.actionUrgency),
                ),
                const SizedBox(width: 4),
                Text(
                  result.actionUrgency.displayName,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleHistoryAction(context, ref, value, index),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'load',
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text('Carregar Dados'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Compartilhar'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildHistoryItemDetails(result),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItemDetails(BodyConditionOutput result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interpretação resumida
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interpretação:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                result.statusDescription,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Métricas resumidas
        Row(
          children: [
            if (result.idealWeightEstimate != null)
              Expanded(
                child: _buildDetailMetric(
                  'Peso Ideal',
                  '${result.idealWeightEstimate!.toStringAsFixed(1)} kg',
                  Icons.target,
                ),
              ),
            if (result.weightAdjustmentNeeded != 0)
              Expanded(
                child: _buildDetailMetric(
                  result.needsWeightLoss ? 'Reduzir' : 'Aumentar',
                  '${result.weightAdjustmentNeeded.abs().toStringAsFixed(1)} kg',
                  result.needsWeightLoss ? Icons.trending_down : Icons.trending_up,
                ),
              ),
            Expanded(
              child: _buildDetailMetric(
                'Risco Metabólico',
                result.metabolicRisk,
                Icons.health_and_safety,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Recomendação principal
        if (result.recommendations.isNotEmpty) ...[
          const Text(
            'Recomendação Principal:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.left(
                width: 3,
                color: _getRecommendationColor(result.recommendations.first.type),
              ),
            ),
            child: Text(
              result.recommendations.first.title,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getUrgencyIcon(ActionUrgency urgency) {
    switch (urgency) {
      case ActionUrgency.urgent:
        return Icons.emergency;
      case ActionUrgency.veterinary:
        return Icons.medical_services;
      case ActionUrgency.monitor:
        return Icons.monitor_heart;
      case ActionUrgency.routine:
        return Icons.check_circle;
    }
  }

  Color _getUrgencyColor(ActionUrgency urgency) {
    switch (urgency) {
      case ActionUrgency.urgent:
        return Colors.red;
      case ActionUrgency.veterinary:
        return Colors.orange;
      case ActionUrgency.monitor:
        return Colors.blue;
      case ActionUrgency.routine:
        return Colors.green;
    }
  }

  Color _getRecommendationColor(NutritionalRecommendationType type) {
    switch (type) {
      case NutritionalRecommendationType.maintain:
        return Colors.green;
      case NutritionalRecommendationType.increaseFood:
        return Colors.orange;
      case NutritionalRecommendationType.decreaseFood:
        return Colors.red;
      case NutritionalRecommendationType.dietaryChange:
        return Colors.blue;
      case NutritionalRecommendationType.specializedDiet:
        return Colors.purple;
    }
  }

  void _handleHistoryAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    int index,
  ) {
    switch (action) {
      case 'load':
        ref.read(bodyConditionProvider.notifier).loadFromHistory(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados carregados na aba "Entrada"')),
        );
        break;
      case 'share':
        // TODO: Implementar compartilhamento
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compartilhamento será implementado em breve')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, index);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir do Histórico'),
        content: const Text('Esta ação não pode ser desfeita. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bodyConditionProvider.notifier).removeFromHistory(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item removido do histórico')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}