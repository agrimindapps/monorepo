import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';

class MedicationStats extends ConsumerWidget {
  const MedicationStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsState = ref.watch(medicationsProvider);
    final theme = Theme.of(context);

    if (medicationsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (medicationsState.error != null) {
      return Center(
        child: Text(
          'Erro ao carregar estatísticas: ${medicationsState.error}',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final medications = medicationsState.medications;
    final activeMedications = medicationsState.activeMedications;
    final expiringMedications = medicationsState.expiringMedications;
    final totalMedications = medications.length;
    final activeCount = activeMedications.length;
    final completedCount = medications.where((m) => m.status == MedicationStatus.completed).length;
    final expiringCount = expiringMedications.length;
    final typeStats = <MedicationType, int>{};
    for (final medication in medications) {
      typeStats[medication.type] = (typeStats[medication.type] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas Gerais',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total',
                  totalMedications.toString(),
                  Icons.medication,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Ativos',
                  activeCount.toString(),
                  Icons.play_circle_filled,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Concluídos',
                  completedCount.toString(),
                  Icons.check_circle,
                  Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Vencendo',
                  expiringCount.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Text(
            'Distribuição por Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildStatusChart(context, medications),
          
          const SizedBox(height: 32),
          Text(
            'Medicamentos por Tipo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...typeStats.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTypeStatRow(
              context,
              entry.key,
              entry.value,
              totalMedications,
            ),
          )),
          
          if (typeStats.isEmpty)
            const Text('Nenhum medicamento cadastrado'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart(BuildContext context, List<Medication> medications) {
    final theme = Theme.of(context);
    
    if (medications.isEmpty) {
      return const Text('Nenhum medicamento para exibir');
    }

    final statusCounts = <MedicationStatus, int>{};
    for (final medication in medications) {
      statusCounts[medication.status] = (statusCounts[medication.status] ?? 0) + 1;
    }

    return Column(
      children: statusCounts.entries.map((entry) {
        final percentage = (entry.value / medications.length) * 100;
        final color = _getStatusColor(entry.key);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.displayName,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeStatRow(
    BuildContext context,
    MedicationType type,
    int count,
    int total,
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total) * 100 : 0.0;
    
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            type.displayName,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 2,
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.scheduled:
        return Colors.blue;
      case MedicationStatus.active:
        return Colors.green;
      case MedicationStatus.completed:
        return Colors.grey;
      case MedicationStatus.discontinued:
        return Colors.orange;
    }
  }
}