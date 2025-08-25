import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/form_section_widget.dart';
import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../providers/fuel_form_provider.dart';

/// Widget principal do formulário de abastecimento
class FuelFormView extends StatelessWidget {
  final FuelFormProvider formProvider;
  final VoidCallback? onSubmit;

  const FuelFormView({
    super.key,
    required this.formProvider,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FuelFormProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final model = provider.formModel;
        final vehicle = model.vehicle;

        if (vehicle == null) {
          return _buildNoVehicleView(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleInfoCard(context, vehicle),
            FormSpacing.section(),
            _buildFuelInfoSection(context, provider),
            FormSpacing.section(),
            _buildValuesSection(context, provider),
            FormSpacing.section(),
            _buildLocationSection(context, provider),
            FormSpacing.section(),
            _buildNotesSection(context, provider),
            SizedBox(height: GasometerDesignTokens.spacingXxxl),
          ],
        );
      },
    );
  }

  Widget _buildNoVehicleView(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum veículo selecionado',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione um veículo primeiro para registrar o abastecimento.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard(BuildContext context, VehicleEntity vehicle) {
    return StandardCard.standard(
      child: Row(
        children: [
          Icon(
            Icons.directions_car,
            size: GasometerDesignTokens.iconSizeAvatar,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: GasometerDesignTokens.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.displayName,
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: GasometerDesignTokens.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: GasometerDesignTokens.spacingXs),
                Text(
                  '${vehicle.color} • ${vehicle.licensePlate}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (vehicle.tankCapacity != null) ...[
                  SizedBox(height: GasometerDesignTokens.spacingXs),
                  Text(
                    'Tanque: ${vehicle.tankCapacity!.toStringAsFixed(0)}L',
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeSm,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelInfoSection(BuildContext context, FuelFormProvider provider) {
    return FormSectionWidget.withTitle(
      title: 'Informações do Combustível',
      icon: Icons.local_gas_station,
      content: Column(
        children: [
          _buildFuelTypeDropdown(context, provider),
          FormSpacing.large(),
          _buildDateField(context, provider),
          FormSpacing.large(),
          _buildFullTankSwitch(context, provider),
        ],
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context, FuelFormProvider provider) {
    return FormSectionWidget.withTitle(
      title: 'Valores',
      icon: Icons.attach_money,
      content: Column(
        children: [
          FormFieldRow.standard(
            children: [
              _buildLitersField(context, provider),
              _buildPricePerLiterField(context, provider),
            ],
          ),
          FormSpacing.large(),
          _buildTotalPriceField(context, provider),
          FormSpacing.large(),
          _buildOdometerField(context, provider),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, FuelFormProvider provider) {
    return FormSectionWidget.withTitle(
      title: 'Local do Abastecimento',
      icon: Icons.location_on,
      content: Column(
        children: [
          _buildGasStationField(context, provider),
          FormSpacing.large(),
          _buildGasStationBrandField(context, provider),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, FuelFormProvider provider) {
    return FormSectionWidget.withTitle(
      title: 'Observações',
      icon: Icons.note_add,
      content: _buildNotesField(context, provider),
    );
  }

  Widget _buildFuelTypeDropdown(BuildContext context, FuelFormProvider provider) {
    final vehicle = provider.formModel.vehicle!;
    final supportedFuels = vehicle.supportedFuels;
    
    return DropdownButtonFormField<FuelType>(
      value: provider.formModel.fuelType,
      decoration: const InputDecoration(
        labelText: 'Tipo de Combustível',
        prefixIcon: Icon(Icons.local_gas_station),
        border: OutlineInputBorder(),
      ),
      items: supportedFuels.map((fuelType) {
        return DropdownMenuItem<FuelType>(
          value: fuelType,
          child: Text(fuelType.displayName),
        );
      }).toList(),
      onChanged: (fuelType) {
        if (fuelType != null) {
          provider.updateFuelType(fuelType);
        }
      },
      validator: (value) => provider.validateField('fuelType', value?.name),
    );
  }

  Widget _buildDateField(BuildContext context, FuelFormProvider provider) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Data',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: _formatDate(provider.formModel.date),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: provider.formModel.date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          provider.updateDate(date);
        }
      },
    );
  }

  Widget _buildFullTankSwitch(BuildContext context, FuelFormProvider provider) {
    return SwitchListTile(
      title: const Text('Tanque Cheio'),
      subtitle: const Text('Marque se encheu completamente o tanque'),
      value: provider.formModel.fullTank,
      onChanged: (value) => provider.updateFullTank(value),
      secondary: const Icon(Icons.water_drop),
    );
  }

  Widget _buildLitersField(BuildContext context, FuelFormProvider provider) {
    final vehicle = provider.formModel.vehicle;
    return ValidatedFormField(
      controller: provider.litersController,
      label: 'Litros',
      hint: '0,000',
      prefixIcon: Icons.local_gas_station,
      required: true,
      validationType: ValidationType.fuelLiters,
      tankCapacity: vehicle?.tankCapacity,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().litersFormatter],
      decoration: const InputDecoration(
        suffixText: 'L',
      ),
      onValidationChanged: (result) {
        // Pode adicionar callback se necessário
      },
    );
  }

  Widget _buildPricePerLiterField(BuildContext context, FuelFormProvider provider) {
    return ValidatedFormField(
      controller: provider.pricePerLiterController,
      label: 'Preço/Litro',
      hint: '0,000',
      required: true,
      validationType: ValidationType.fuelPrice,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().priceFormatter],
      decoration: const InputDecoration(
        prefixText: 'R\$ ',
      ),
      onValidationChanged: (result) {
        // Pode adicionar callback se necessário
      },
    );
  }

  Widget _buildTotalPriceField(BuildContext context, FuelFormProvider provider) {
    final formatter = FuelFormatterService();
    final totalPrice = provider.formModel.totalPrice;
    
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Valor Total',
        prefixText: 'R\$ ',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: totalPrice > 0 ? formatter.formatTotalPrice(totalPrice) : '',
      ),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOdometerField(BuildContext context, FuelFormProvider provider) {
    final vehicle = provider.formModel.vehicle;
    return ValidatedFormField(
      controller: provider.odometerController,
      label: 'Odômetro',
      hint: '0,0',
      prefixIcon: Icons.speed,
      required: true,
      validationType: ValidationType.decimal, // Usar validação decimal por enquanto
      currentOdometer: vehicle?.currentOdometer,
      minValue: 0.0,
      maxValue: 9999999.0,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().odometerFormatter],
      decoration: const InputDecoration(
        suffixText: 'km',
      ),
      onValidationChanged: (result) {
        // Pode adicionar callback se necessário
      },
    );
  }

  Widget _buildGasStationField(BuildContext context, FuelFormProvider provider) {
    return ValidatedFormField(
      controller: provider.gasStationController,
      label: 'Nome do Posto (opcional)',
      hint: 'Ex: Shell, Petrobras, Ipiranga...',
      prefixIcon: Icons.local_gas_station_outlined,
      required: false,
      validationType: ValidationType.length,
      minLength: 2,
      maxLengthValidation: 100,
      onValidationChanged: (result) {
        // Pode adicionar callback se necessário
      },
    );
  }

  Widget _buildGasStationBrandField(BuildContext context, FuelFormProvider provider) {
    return TextFormField(
      controller: provider.gasStationBrandController,
      decoration: const InputDecoration(
        labelText: 'Bandeira/Rede (opcional)',
        hintText: 'Ex: BR, Shell Select...',
        prefixIcon: Icon(Icons.business),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildNotesField(BuildContext context, FuelFormProvider provider) {
    return ValidatedFormField(
      controller: provider.notesController,
      label: 'Observações (opcional)',
      hint: 'Adicione comentários sobre este abastecimento...',
      prefixIcon: Icons.note_add,
      required: false,
      validationType: ValidationType.length,
      maxLengthValidation: FuelConstants.maxNotesLength,
      maxLines: 3,
      maxLength: FuelConstants.maxNotesLength,
      showCharacterCount: true,
      onValidationChanged: (result) {
        // Pode adicionar callback se necessário
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}