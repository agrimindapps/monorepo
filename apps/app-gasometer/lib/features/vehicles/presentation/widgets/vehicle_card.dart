import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../domain/entities/vehicle_entity.dart';
import 'vehicle_card_actions.dart';
import 'vehicle_card_content.dart';
import 'vehicle_card_header.dart';

/// Reusable vehicle card widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying a vehicle card
/// Follows OCP: Open for extension via custom actions and content
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showActions = true,
  });

  final VehicleEntity vehicle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final semanticLabel = 'Veículo ${vehicle.brand} ${vehicle.model} ${vehicle.year}, placa ${vehicle.licensePlate}, ${vehicle.currentOdometer.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} km';
    
    return SemanticCard(
      semanticLabel: semanticLabel,
      semanticHint: 'Card com informações do veículo. ${showActions ? 'Contém botões para editar ou excluir' : ''}',
      onTap: onTap,
      child: Column(
        children: [
          VehicleCardHeader(vehicle: vehicle),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          VehicleCardContent(vehicle: vehicle),
          if (showActions)
            VehicleCardActions(
              vehicle: vehicle,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
        ],
      ),
    );
  }
}