import 'package:flutter/material.dart';
import 'enhanced_vehicle_selector.dart';

/// Widget de seleção de veículo - Mantido para compatibilidade
/// Use [EnhancedVehicleSelector] para novas implementações
@Deprecated('Use EnhancedVehicleSelector para melhor experiência do usuário')
class VehicleSelector extends StatelessWidget {
  final String? selectedVehicleId;
  final void Function(String?) onVehicleChanged;
  final String? hintText;
  final bool showEmptyOption;

  const VehicleSelector({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    this.hintText = 'Selecione um veículo',
    this.showEmptyOption = false,
  });

  @override
  Widget build(BuildContext context) {
    // Redireciona para o novo seletor melhorado
    return EnhancedVehicleSelector(
      selectedVehicleId: selectedVehicleId,
      onVehicleChanged: onVehicleChanged,
      hintText: hintText,
    );
  }

}