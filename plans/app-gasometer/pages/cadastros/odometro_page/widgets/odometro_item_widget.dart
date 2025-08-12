// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../database/20_odometro_model.dart';

/// Widget otimizado para exibir um item de odômetro
class OdometroItemWidget extends StatelessWidget {
  final OdometroCar odometro;
  final double difference;
  final VoidCallback onTap;

  const OdometroItemWidget({
    super.key,
    required this.odometro,
    required this.difference,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(odometro.data);
    final dayOfMonth = DateFormat('dd').format(date);
    final weekday = DateFormat('EEE', 'pt_BR').format(date).toUpperCase();

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Data e Dia da Semana
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      color: ShadcnStyle.mutedTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayOfMonth,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 40, color: ShadcnStyle.borderColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          icon: Icons.speed,
                          value: '${odometro.odometro.toStringAsFixed(1)} km',
                          label: 'Hodômetro',
                          isHighlighted: true,
                        ),
                        if (difference != 0)
                          _buildInfoItem(
                            icon: Icons.trending_up,
                            value: '${difference.abs().toStringAsFixed(1)} km',
                            label: 'Diferença',
                            isHighlighted: false,
                          ),
                      ],
                    ),
                    if (odometro.descricao.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        odometro.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: ShadcnStyle.mutedTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHighlighted
                ? ShadcnStyle.textColor.withValues(alpha: 0.1)
                : ShadcnStyle.borderColor.withValues(alpha: 0.3),
            borderRadius: ShadcnStyle.borderRadius,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? ShadcnStyle.textColor
                : ShadcnStyle.mutedTextColor,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? ShadcnStyle.textColor
                    : ShadcnStyle.mutedTextColor,
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
        ),
      ],
    );
  }
}
