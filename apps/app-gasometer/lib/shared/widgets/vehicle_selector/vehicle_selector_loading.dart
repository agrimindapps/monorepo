import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';

class VehicleSelectorLoading extends StatelessWidget {
  const VehicleSelectorLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando lista de veículos',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.xlarge,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: AppSpacing.large),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Carregando veículos...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: AppFontWeights.medium,
                      fontSize: AppFontSizes.medium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preparando sua lista personalizada',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: AppOpacity.medium,
                          ),
                      fontSize: AppFontSizes.small,
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
}
