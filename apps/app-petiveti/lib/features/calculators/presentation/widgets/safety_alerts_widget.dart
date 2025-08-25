import 'package:flutter/material.dart';

import '../../domain/entities/medication_dosage_output.dart';

/// Widget para exibir alertas de segurança da dosagem
class SafetyAlertsWidget extends StatelessWidget {
  const SafetyAlertsWidget({
    super.key,
    required this.alerts,
  });

  final List<SafetyAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return _buildNoAlertsCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas de Segurança',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: _getHeaderColor(),
          ),
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertCard(alert, context),
        )),
      ],
    );
  }

  Widget _buildNoAlertsCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sem Alertas de Segurança',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A dosagem calculada está dentro dos parâmetros seguros.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
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

  Widget _buildAlertCard(SafetyAlert alert, BuildContext context) {
    final color = _getAlertColor(alert.level);
    final icon = _getAlertIcon(alert.level);

    return Card(
      color: color.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.shade200,
          width: alert.isBlocking ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: color.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.type.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: color.shade800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              alert.level.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: color.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: color.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (alert.recommendation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: color.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recomendação:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.recommendation!,
                            style: TextStyle(
                              fontSize: 13,
                              color: color.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (alert.isBlocking) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.block,
                      color: Colors.red.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ATENÇÃO: Este alerta impede a administração segura do medicamento.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getHeaderColor() {
    if (alerts.isEmpty) return Colors.green;
    
    final hasBlocking = alerts.any((alert) => alert.isBlocking);
    final hasDanger = alerts.any((alert) => alert.level == AlertLevel.danger);
    
    if (hasBlocking || hasDanger) return Colors.red;
    if (alerts.any((alert) => alert.level == AlertLevel.warning)) return Colors.orange;
    if (alerts.any((alert) => alert.level == AlertLevel.caution)) return Colors.yellow.shade700;
    
    return Colors.green;
  }

  MaterialColor _getAlertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.safe:
        return Colors.green;
      case AlertLevel.caution:
        return Colors.yellow;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.danger:
        return Colors.red;
    }
  }

  IconData _getAlertIcon(AlertLevel level) {
    switch (level) {
      case AlertLevel.safe:
        return Icons.check_circle_outline;
      case AlertLevel.caution:
        return Icons.info_outline;
      case AlertLevel.warning:
        return Icons.warning_amber;
      case AlertLevel.danger:
        return Icons.error_outline;
    }
  }
}