// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';

/// Widget otimizado para exibir cabeçalho de estatísticas mensais do odômetro
class MonthlyStatsHeader extends StatelessWidget {
  final Map<String, double> statistics;

  const MonthlyStatsHeader({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: ShadcnStyle.backgroundColor,
          borderRadius: ShadcnStyle.borderRadius,
          border: Border.all(color: ShadcnStyle.borderColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.speed,
                label: 'Km Inicial',
                value: '${statistics['kmInicial']!.toStringAsFixed(1)} km',
                color: ShadcnStyle.textColor,
              ),
            ),
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.speed,
                label: 'Km Final',
                value: '${statistics['kmFinal']!.toStringAsFixed(1)} km',
                color: ShadcnStyle.textColor,
              ),
            ),
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.timeline,
                label: 'Total',
                value: '${statistics['distanciaTotal']!.toStringAsFixed(1)} km',
                color: ShadcnStyle.textColor,
              ),
            ),
            Expanded(
              child: _buildHeaderInfo(
                icon: Icons.analytics,
                label: 'Média Km/Dia',
                value: '${statistics['mediaKmDia']!.toStringAsFixed(1)} km',
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ShadcnStyle.textColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ShadcnStyle.textColor, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: ShadcnStyle.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ShadcnStyle.mutedTextColor,
          ),
        ),
      ],
    );
  }
}
