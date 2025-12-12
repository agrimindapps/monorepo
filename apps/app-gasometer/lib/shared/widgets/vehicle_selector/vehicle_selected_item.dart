import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleSelectedItem extends StatelessWidget {
  const VehicleSelectedItem({
    super.key,
    required this.vehicle,
  });

  final VehicleEntity vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // Marca/Modelo
                Flexible(
                  child: Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: TextStyle(
                      fontWeight: AppFontWeights.semiBold,
                      fontSize: AppFontSizes.body,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Placa
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppRadius.small,
                    ),
                  ),
                  child: Text(
                    vehicle.licensePlate,
                    style: TextStyle(
                      fontSize: AppFontSizes.xs,
                      fontWeight: AppFontWeights.medium,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Ícone odômetro
                Icon(
                  Icons.speed,
                  size: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(
                        alpha: AppOpacity.medium,
                      ),
                ),
                const SizedBox(width: 2),
                // Odômetro
                Text(
                  '${vehicle.currentOdometer.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontSize: AppFontSizes.xs,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                          alpha: AppOpacity.medium,
                        ),
                    fontWeight: AppFontWeights.medium,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          if (!vehicle.isActive) ...[
            const SizedBox(width: AppSpacing.small),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppRadius.small,
                ),
              ),
              child: Icon(
                Icons.pause_circle_outline,
                size: AppSizes.iconXS,
                color: Theme.of(
                  context,
                ).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
