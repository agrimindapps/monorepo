import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fuel_form_provider.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../../core/constants/fuel_constants.dart';

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
            const SizedBox(height: FuelConstants.sectionSpacing),
            _buildFuelInfoSection(context, provider),
            const SizedBox(height: FuelConstants.sectionSpacing),
            _buildValuesSection(context, provider),
            const SizedBox(height: FuelConstants.sectionSpacing),
            _buildLocationSection(context, provider),
            const SizedBox(height: FuelConstants.sectionSpacing),
            _buildNotesSection(context, provider),
            const SizedBox(height: 32),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.directions_car,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.color} • ${vehicle.licensePlate}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (vehicle.tankCapacity != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tanque: ${vehicle.tankCapacity!.toStringAsFixed(0)}L',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelInfoSection(BuildContext context, FuelFormProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Combustível',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildFuelTypeDropdown(context, provider),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildDateField(context, provider),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildFullTankSwitch(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context, FuelFormProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valores',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FuelConstants.fieldSpacing),
            Row(
              children: [
                Expanded(
                  child: _buildLitersField(context, provider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPricePerLiterField(context, provider),
                ),
              ],
            ),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildTotalPriceField(context, provider),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildOdometerField(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, FuelFormProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local do Abastecimento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildGasStationField(context, provider),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildGasStationBrandField(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, FuelFormProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FuelConstants.fieldSpacing),
            _buildNotesField(context, provider),
          ],
        ),
      ),
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
    return TextFormField(
      controller: provider.litersController,
      decoration: InputDecoration(
        labelText: 'Litros',
        hintText: '0,000',
        prefixIcon: const Icon(Icons.local_gas_station),
        suffixText: 'L',
        border: const OutlineInputBorder(),
        errorText: provider.formModel.getFieldError('liters'),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().litersFormatter],
      validator: (value) => provider.validateField('liters', value),
    );
  }

  Widget _buildPricePerLiterField(BuildContext context, FuelFormProvider provider) {
    return TextFormField(
      controller: provider.pricePerLiterController,
      decoration: InputDecoration(
        labelText: 'Preço/Litro',
        hintText: '0,000',
        prefixText: 'R\$ ',
        border: const OutlineInputBorder(),
        errorText: provider.formModel.getFieldError('pricePerLiter'),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().priceFormatter],
      validator: (value) => provider.validateField('pricePerLiter', value),
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
    return TextFormField(
      controller: provider.odometerController,
      decoration: InputDecoration(
        labelText: 'Odômetro',
        hintText: '0,0',
        prefixIcon: const Icon(Icons.speed),
        suffixText: 'km',
        border: const OutlineInputBorder(),
        errorText: provider.formModel.getFieldError('odometer'),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().odometerFormatter],
      validator: (value) => provider.validateField('odometer', value),
    );
  }

  Widget _buildGasStationField(BuildContext context, FuelFormProvider provider) {
    return TextFormField(
      controller: provider.gasStationController,
      decoration: InputDecoration(
        labelText: 'Nome do Posto',
        hintText: 'Ex: Shell, Petrobras, Ipiranga...',
        prefixIcon: const Icon(Icons.local_gas_station_outlined),
        border: const OutlineInputBorder(),
        errorText: provider.formModel.getFieldError('gasStationName'),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) => provider.validateField('gasStationName', value),
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
    return TextFormField(
      controller: provider.notesController,
      decoration: InputDecoration(
        labelText: 'Observações (opcional)',
        hintText: 'Adicione comentários sobre este abastecimento...',
        prefixIcon: const Icon(Icons.note_add),
        border: const OutlineInputBorder(),
        errorText: provider.formModel.getFieldError('notes'),
      ),
      maxLines: 3,
      maxLength: FuelConstants.maxNotesLength,
      validator: (value) => provider.validateField('notes', value),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}