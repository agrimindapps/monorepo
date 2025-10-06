import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Vehicle card actions widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying action buttons
/// Follows OCP: Open for extension via custom actions
class VehicleCardActions extends StatelessWidget {
  const VehicleCardActions({
    super.key,
    required this.vehicle,
    this.onEdit,
    this.onDelete,
  });

  final VehicleEntity vehicle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GasometerDesignTokens.spacingLg,
        vertical: GasometerDesignTokens.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onEdit != null) ...[
            SemanticButton.icon(
              semanticLabel: 'Editar veículo ${vehicle.brand} ${vehicle.model}',
              semanticHint: 'Toque para editar as informações do veículo',
              onPressed: onEdit,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(GasometerDesignTokens.spacingSm),
                minimumSize: const Size(
                  GasometerDesignTokens.minTouchTarget,
                  GasometerDesignTokens.minTouchTarget,
                ),
              ),
              child: const Icon(Icons.edit_outlined),
            ),
            const SizedBox(width: GasometerDesignTokens.spacingSm),
          ],
          if (onDelete != null)
            SemanticButton.icon(
              semanticLabel: 'Excluir veículo ${vehicle.brand} ${vehicle.model}',
              semanticHint: 'Toque para remover o veículo permanentemente',
              onPressed: () => _showDeleteConfirmation(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.all(GasometerDesignTokens.spacingSm),
                minimumSize: const Size(
                  GasometerDesignTokens.minTouchTarget,
                  GasometerDesignTokens.minTouchTarget,
                ),
              ),
              child: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o veículo ${vehicle.brand} ${vehicle.model}?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}