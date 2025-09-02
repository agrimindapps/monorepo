import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Vehicle card content widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying vehicle details
/// Follows OCP: Open for extension via custom content layout
class VehicleCardContent extends StatelessWidget {
  const VehicleCardContent({
    super.key,
    required this.vehicle,
  });

  final VehicleEntity vehicle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GasometerDesignTokens.spacingLg,
        vertical: GasometerDesignTokens.spacingMd,
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            'Placa',
            vehicle.licensePlate,
            Icons.confirmation_number_outlined,
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildDetailRow(
            context,
            'Quilometragem',
            '${_formatNumber(vehicle.currentOdometer)} km',
            Icons.speed,
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildDetailRow(
            context,
            'Combustível',
            'Gasolina', // TODO: Add fuel type to VehicleEntity
            Icons.local_gas_station_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Semantics(
          label: '$label: $value',
          hint: 'Informação do veículo',
          child: Icon(
            icon,
            size: GasometerDesignTokens.iconSizeSm,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: GasometerDesignTokens.opacitySecondary,
            ),
          ),
        ),
        SizedBox(width: GasometerDesignTokens.spacingSm),
        SemanticText.label(
          label,
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeMd,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: GasometerDesignTokens.opacitySecondary,
            ),
          ),
        ),
        const Spacer(),
        SemanticText(
          value,
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeMd,
            fontWeight: GasometerDesignTokens.fontWeightMedium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatNumber(num number) {
    return number.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}