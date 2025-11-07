import 'package:flutter/material.dart';
import 'enhanced_vehicle_selector.dart';

/// Widget de seleção de veículo - Mantido para compatibilidade
/// Use [EnhancedVehicleSelector] para novas implementações
@Deprecated('Use EnhancedVehicleSelector para melhor experiência do usuário')
class VehicleSelector extends StatelessWidget {

  const VehicleSelector({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    this.hintText = 'Selecione um veículo',
    this.showEmptyOption = false,
  });
  final String? selectedVehicleId;
  final void Function(String?) onVehicleChanged;
  final String? hintText;
  final bool showEmptyOption;

  @override
  Widget build(BuildContext context) {
    return EnhancedVehicleSelector(
      selectedVehicleId: selectedVehicleId,
      onVehicleChanged: onVehicleChanged,
      hintText: hintText,
    );
  }

}
