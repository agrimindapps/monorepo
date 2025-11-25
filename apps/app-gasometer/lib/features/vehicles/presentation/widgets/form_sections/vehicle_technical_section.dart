import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/form_section_header.dart';
import '../../../domain/entities/fuel_type_mapper.dart';
import '../../providers/vehicle_form_notifier.dart';

/// Technical information section (Fuel Type Selector)
class VehicleTechnicalSection extends ConsumerWidget {
  const VehicleTechnicalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormSectionHeader(
      title: 'Informações Técnicas',
      icon: Icons.speed,
      child: Column(
        children: [
          _buildFuelTypeSelector(context, ref),
        ],
      ),
    );
  }

  Widget _buildFuelTypeSelector(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(vehicleFormProvider);
    final notifier = ref.read(vehicleFormProvider.notifier);

    final fuelOptions = FuelTypeMapper.availableFuelStrings.map((fuelName) {
      IconData icon;
      switch (fuelName) {
        case 'Gasolina':
          icon = Icons.local_gas_station;
          break;
        case 'Etanol':
          icon = Icons.eco;
          break;
        case 'Diesel':
          icon = Icons.local_shipping;
          break;
        case 'Diesel S-10':
          icon = Icons.local_gas_station;
          break;
        case 'GNV':
        case 'Gás':
          icon = Icons.circle;
          break;
        case 'Energia Elétrica':
        case 'Elétrico':
          icon = Icons.electric_car;
          break;
        case 'Híbrido':
          icon = Icons.ev_station;
          break;
        default:
          icon = Icons.local_gas_station;
      }
      return {'name': fuelName, 'icon': icon};
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Combustível',
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeMd,
            fontWeight: GasometerDesignTokens.fontWeightMedium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: GasometerDesignTokens.spacingMd),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fuelOptions.map((fuel) {
            final isSelected = formState.selectedFuel == fuel['name'];
            return GestureDetector(
              onTap: () => notifier.updateSelectedFuel(fuel['name'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        fuel['icon'] as IconData,
                        size: 14,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fuel['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
