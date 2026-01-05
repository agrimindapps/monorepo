import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../features/vehicles/domain/entities/vehicle_entity.dart';
import 'vehicle_dropdown_item.dart';
import 'vehicle_selected_item.dart';

class VehicleSelectorDropdown extends StatelessWidget {
  const VehicleSelectorDropdown({
    super.key,
    required this.vehicles,
    required this.currentSelectedVehicleId,
    required this.hintText,
    required this.enabled,
    required this.fadeAnimation,
    required this.isExpanded,
    required this.onVehicleSelected,
    required this.onDropdownTap,
  });

  final List<VehicleEntity> vehicles;
  final String? currentSelectedVehicleId;
  final String? hintText;
  final bool enabled;
  final Animation<double> fadeAnimation;
  final bool isExpanded;
  final void Function(String?) onVehicleSelected;
  final VoidCallback onDropdownTap;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = currentSelectedVehicleId != null
        ? vehicles.firstWhere(
            (v) => v.id == currentSelectedVehicleId,
            orElse: () => vehicles.first,
          )
        : null;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: selectedVehicle != null
          ? 'Veículo selecionado: ${selectedVehicle.brand} ${selectedVehicle.model}, ${selectedVehicle.licensePlate}'
          : 'Selecionar veículo',
      button: true,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedVehicle != null
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.6 : 0.5)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.3),
              width: selectedVehicle != null ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(15),
            color: isDark
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: currentSelectedVehicleId,
            isDense: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.medium,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              // Remove espaço reservado para helper/error text
              helperText: ' ',
              helperStyle: const TextStyle(height: 0, fontSize: 0),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              isCollapsed: false,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: AppOpacity.medium),
                fontSize: AppFontSizes.medium,
                fontWeight: AppFontWeights.regular,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(
                  left: AppSpacing.medium,
                ),
                child: Icon(
                  Icons.directions_car,
                  color: selectedVehicle != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: AppOpacity.subtle),
                  size: AppSizes.iconM,
                ),
              ),
            ),
            selectedItemBuilder: (BuildContext context) {
              return vehicles.map<Widget>((VehicleEntity vehicle) {
                final isSelected = vehicle.id == currentSelectedVehicleId;
                if (!isSelected) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: const SizedBox.shrink(),
                  );
                }
                return VehicleSelectedItem(vehicle: vehicle);
              }).toList();
            },
            items: vehicles.map<DropdownMenuItem<String>>((
              VehicleEntity vehicle,
            ) {
              final isCurrentlySelected =
                  vehicle.id == currentSelectedVehicleId;

              return DropdownMenuItem<String>(
                value: vehicle.id,
                child: VehicleDropdownItem(
                  vehicle: vehicle,
                  isSelected: isCurrentlySelected,
                ),
              );
            }).toList(),
            onChanged: enabled ? onVehicleSelected : null,
            onTap: onDropdownTap,
            isExpanded: true,
            icon: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: AppDurations.fast,
              child: Icon(
                Icons.expand_more,
                color: enabled
                    ? (selectedVehicle != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(
                              alpha: AppOpacity.prominent,
                            ))
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: AppOpacity.disabled),
                size: AppSizes.iconM,
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppFontSizes.medium,
            ),
            dropdownColor: isDark
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            elevation: 0,
            itemHeight: 80,
            menuMaxHeight: 400,
          ),
        ),
      ),
    );
  }
}
