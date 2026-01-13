import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/rain_gauge_entity.dart';

class RainGaugeCardWidget extends StatelessWidget {
  final RainGaugeEntity rainGauge;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RainGaugeCardWidget({
    super.key,
    required this.rainGauge,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(rainGauge.statusColor, colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Header with Status Strip
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: statusColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  rainGauge.locationName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusBadge(context, statusColor),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${rainGauge.deviceId} • Modelo: ${rainGauge.deviceModel}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20),
                                  SizedBox(width: 8),
                                  Text('Excluir'),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Metrics Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      context,
                      'Chuva Hoje',
                      '${rainGauge.dailyAccumulation.toStringAsFixed(1)} mm',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: _buildMetric(
                      context,
                      'Acum. Mês',
                      '${rainGauge.monthlyAccumulation.toStringAsFixed(1)} mm',
                      Icons.calendar_today,
                      Colors.indigo,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: _buildMetric(
                      context,
                      'Última Leitura',
                      _formatLastUpdate(rainGauge.lastMeasurement),
                      Icons.access_time,
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        rainGauge.status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String statusColorName, ColorScheme scheme) {
    switch (statusColorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return scheme.error;
      case 'gray':
      default:
        return scheme.outline;
    }
  }

  String _formatLastUpdate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m atrás';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h atrás';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}
