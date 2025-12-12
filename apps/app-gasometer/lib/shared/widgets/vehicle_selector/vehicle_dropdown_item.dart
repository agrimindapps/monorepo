import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleDropdownItem extends StatelessWidget {
  const VehicleDropdownItem({
    super.key,
    required this.vehicle,
    required this.isSelected,
  });

  final VehicleEntity vehicle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.medium,
        horizontal: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              AppSpacing.small,
            ),
            decoration: BoxDecoration(
              color: vehicle.isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                AppRadius.medium,
              ),
            ),
            child: Icon(
              vehicle.isActive
                  ? Icons.directions_car
                  : Icons.directions_car_outlined,
              size: AppSizes.iconS,
              color: vehicle.isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? AppFontWeights.semiBold
                              : AppFontWeights.medium,
                          fontSize: AppFontSizes.medium,
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (!vehicle.isActive)
                      Container(
                        margin: const EdgeInsets.only(
                          left: AppSpacing.small,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppRadius.small,
                          ),
                        ),
                        child: Text(
                          'INATIVO',
                          style: TextStyle(
                            fontSize: AppFontSizes.xs,
                            fontWeight: AppFontWeights.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppRadius.small,
                        ),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        vehicle.licensePlate,
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          fontWeight: AppFontWeights.medium,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.medium,
                    ),
                    Icon(
                      Icons.speed,
                      size: AppSizes.iconXS,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: AppOpacity.medium,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${vehicle.currentOdometer.toStringAsFixed(0)} km',
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(
                              alpha: AppOpacity.medium,
                            ),
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: AppSizes.iconS,
              color: Theme.of(
                context,
              ).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
