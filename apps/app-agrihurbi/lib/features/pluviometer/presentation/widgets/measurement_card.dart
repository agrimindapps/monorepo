import 'package:flutter/material.dart';

import '../../domain/entities/rainfall_measurement_entity.dart';

/// Card para exibir uma medição pluviométrica na lista
class MeasurementCard extends StatelessWidget {
  const MeasurementCard({
    super.key,
    required this.measurement,
    required this.gaugeName,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final RainfallMeasurementEntity measurement;
  final String gaugeName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determina cor baseada na quantidade
    Color amountColor;
    if (measurement.amount < 5) {
      amountColor = Colors.lightBlue;
    } else if (measurement.amount < 20) {
      amountColor = Colors.blue;
    } else if (measurement.amount < 50) {
      amountColor = Colors.indigo;
    } else {
      amountColor = Colors.deepPurple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de quantidade
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: amountColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: amountColor,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      measurement.amount.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'mm',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: amountColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gaugeName,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(measurement.measurementDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (measurement.observations != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              measurement.observations!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Menu de ações
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
