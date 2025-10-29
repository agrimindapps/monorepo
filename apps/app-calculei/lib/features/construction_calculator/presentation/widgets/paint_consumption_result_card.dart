import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/paint_consumption_calculation.dart';

/// Result card for paint consumption calculation
class PaintConsumptionResultCard extends StatelessWidget {
  const PaintConsumptionResultCard({
    super.key,
    required this.calculation,
  });

  final PaintConsumptionCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('pt_BR');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Resultado do Cálculo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Results Grid
              Row(
                children: [
                  // Left Column - Inputs
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResultItem(
                          label: 'Área',
                          value: '${numberFormat.format(calculation.area)} m²',
                          icon: Icons.square_foot,
                        ),
                        const SizedBox(height: 16),
                        _ResultItem(
                          label: 'Demãos',
                          value:
                              '${calculation.coats.toInt()} demão${calculation.coats > 1 ? 's' : ''}',
                          icon: Icons.layers,
                        ),
                        const SizedBox(height: 16),
                        _ResultItem(
                          label: 'Fator de superfície',
                          value: _getSurfacePreparationText(
                              calculation.surfacePreparation),
                          icon: Icons.texture,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Column - Results
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_paint,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tinta Necessária',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${numberFormat.format(calculation.paintQuantity)} L',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${numberFormat.format(calculation.buckets)} balde${calculation.buckets > 1 ? 's' : ''} (18L)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Additional Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recomenda-se comprar 10-15% a mais de tinta para compensar perdas durante a aplicação. Consulte o rendimento específico da tinta escolhida.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSurfacePreparationText(double factor) {
    switch (factor) {
      case 1.0:
        return 'Parede nova';
      case 1.2:
        return 'Repintura';
      case 1.5:
        return 'Irregular';
      case 2.0:
        return 'Muito irregular';
      default:
        return 'Fator ${factor.toStringAsFixed(1)}';
    }
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
