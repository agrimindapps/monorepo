import 'package:flutter/material.dart';

import 'enhanced_vehicle_selector.dart';

/// Unified vehicle selector section wrapper
/// 
/// Provides consistent padding and layout for the vehicle selector
/// across all record pages.
/// 
/// Example:
/// ```dart
/// VehicleSelectorSection(
///   selectedVehicleId: _selectedVehicleId,
///   onVehicleChanged: (vehicleId) {
///     setState(() => _selectedVehicleId = vehicleId);
///     // Apply filter logic
///   },
/// )
/// ```
class VehicleSelectorSection extends StatelessWidget {
  const VehicleSelectorSection({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
    this.hintText = 'Selecione um veículo',
  });

  /// Currently selected vehicle ID
  final String? selectedVehicleId;

  /// Callback when vehicle selection changes
  final ValueChanged<String?> onVehicleChanged;

  /// Hint text to display when no vehicle is selected
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0.0),
      child: EnhancedVehicleSelector(
        selectedVehicleId: selectedVehicleId,
        onVehicleChanged: onVehicleChanged,
        hintText: hintText,
      ),
    );
  }
}
