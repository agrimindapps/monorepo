import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Vehicle card header widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying vehicle header info
/// Follows OCP: Open for extension via custom styling
class VehicleCardHeader extends StatelessWidget {
  const VehicleCardHeader({
    super.key,
    required this.vehicle,
    this.showIcon = true,
  });

  final VehicleEntity vehicle;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingLg,
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Semantics(
              label: 'Ícone do veículo',
              hint: 'Representação visual do veículo ${vehicle.brand} ${vehicle.model}',
              child: CircleAvatar(
                radius: GasometerDesignTokens.iconSizeAvatar / 2,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(
                  alpha: GasometerDesignTokens.opacityOverlay,
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Theme.of(context).colorScheme.primary,
                  size: GasometerDesignTokens.iconSizeListItem,
                ),
              ),
            ),
            const SizedBox(width: GasometerDesignTokens.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemanticText.heading(
                  '${vehicle.brand} ${vehicle.model}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: GasometerDesignTokens.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SemanticText.subtitle(
                  '${vehicle.year} • ${vehicle.color}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: GasometerDesignTokens.opacitySecondary,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
