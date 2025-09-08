import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/centralized_loading_widget.dart';
import '../../../../core/presentation/widgets/form_section_widget.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../providers/fuel_form_provider.dart';

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
          return const CentralizedLoadingWidget(
            message: FuelConstants.loadingFormMessage,
          );
        }

        final model = provider.formModel;
        final vehicle = model.vehicle;

        if (vehicle == null) {
          return _buildNoVehicleView(context);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFuelInfoSection(context, provider),
              const SizedBox(height: 16),
              _buildValuesSection(context, provider),
              const SizedBox(height: 16),
              _buildLocationSection(context, provider),
              const SizedBox(height: 16),
              _buildNotesSection(context, provider),
            ],
          ),
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
                FuelConstants.noVehicleSelected,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                FuelConstants.selectVehicleMessage,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildFuelInfoSection(BuildContext context, FuelFormProvider provider) {
    return FormSectionWidget.withTitle(
      title: FuelConstants.fuelInfoSection,
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
      title: FuelConstants.valuesSection,
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
      title: FuelConstants.locationSection,
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
      title: FuelConstants.notesSection,
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
        labelText: FuelConstants.fuelTypeLabel,
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
        labelText: FuelConstants.dateLabel,
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
          locale: const Locale('pt', 'BR'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          provider.updateDate(date);
        }
      },
    );
  }

  Widget _buildFullTankSwitch(BuildContext context, FuelFormProvider provider) {
    return Semantics(
      label: provider.formModel.fullTank 
        ? 'Tanque cheio ativado'
        : 'Tanque cheio desativado',
      hint: 'Toque para alterar se o tanque foi completamente abastecido',
      child: SwitchListTile(
        title: const Text(FuelConstants.fullTankLabel),
        subtitle: const Text(FuelConstants.fullTankSubtitle),
        value: provider.formModel.fullTank,
        onChanged: (value) => provider.updateFullTank(value),
        secondary: const Icon(Icons.water_drop),
      ),
    );
  }

  Widget _buildLitersField(BuildContext context, FuelFormProvider provider) {
    final vehicle = provider.formModel.vehicle;
    final error = provider.formModel.errors['liters'];
    
    return ValidatedFormField(
      controller: provider.litersController,
      label: FuelConstants.litersLabel,
      hint: FuelConstants.litersPlaceholder,
      prefixIcon: Icons.local_gas_station,
      required: true,
      validationType: ValidationType.fuelLiters,
      tankCapacity: vehicle?.tankCapacity,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().litersFormatter],
      decoration: InputDecoration(
        suffixText: 'L',
        errorText: error,
      ),
      onValidationChanged: (result) {},
    );
  }

  Widget _buildPricePerLiterField(BuildContext context, FuelFormProvider provider) {
    final error = provider.formModel.errors['pricePerLiter'];
    
    return ValidatedFormField(
      controller: provider.pricePerLiterController,
      label: FuelConstants.pricePerLiterLabel,
      hint: FuelConstants.pricePlaceholder,
      required: true,
      validationType: ValidationType.fuelPrice,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().priceFormatter],
      decoration: InputDecoration(
        prefixText: 'R\$ ',
        errorText: error,
      ),
      onValidationChanged: (result) {},
    );
  }

  Widget _buildTotalPriceField(BuildContext context, FuelFormProvider provider) {
    final formatter = FuelFormatterService();
    final totalPrice = provider.formModel.totalPrice;
    
    return TextFormField(
      decoration: const InputDecoration(
        labelText: FuelConstants.totalPriceLabel,
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
    final error = provider.formModel.errors['odometer'];
    
    return ValidatedFormField(
      controller: provider.odometerController,
      label: FuelConstants.odometerLabel,
      hint: FuelConstants.odometerPlaceholder,
      prefixIcon: Icons.speed,
      required: true,
      validationType: ValidationType.odometer, // Usar validação de odômetro específica
      currentOdometer: vehicle?.currentOdometer,
      initialOdometer: provider.lastOdometerReading,
      minValue: 0.0,
      maxValue: 9999999.0,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FuelFormatterService().odometerFormatter],
      decoration: InputDecoration(
        suffixText: 'km',
        errorText: error,
      ),
      onValidationChanged: (result) {},
    );
  }

  Widget _buildGasStationField(BuildContext context, FuelFormProvider provider) {
    final error = provider.formModel.errors['gasStationName'];
    
    return ValidatedFormField(
      controller: provider.gasStationController,
      label: FuelConstants.gasStationLabel,
      hint: FuelConstants.gasStationHint,
      prefixIcon: Icons.local_gas_station_outlined,
      required: false,
      validationType: ValidationType.length,
      minLength: 2,
      maxLengthValidation: 100,
      decoration: error != null ? InputDecoration(
        errorText: error,
      ) : null,
      onValidationChanged: (result) {},
    );
  }

  Widget _buildGasStationBrandField(BuildContext context, FuelFormProvider provider) {
    return TextFormField(
      controller: provider.gasStationBrandController,
      decoration: const InputDecoration(
        labelText: FuelConstants.gasStationBrandLabel,
        hintText: FuelConstants.gasStationBrandHint,
        prefixIcon: Icon(Icons.business),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildNotesField(BuildContext context, FuelFormProvider provider) {
    return ValidatedFormField(
      controller: provider.notesController,
      label: FuelConstants.notesLabel,
      hint: FuelConstants.notesHint,
      prefixIcon: Icons.note_add,
      required: false,
      validationType: ValidationType.length,
      maxLengthValidation: FuelConstants.maxNotesLength,
      maxLines: 3,
      maxLength: FuelConstants.maxNotesLength,
      showCharacterCount: true,
      onValidationChanged: (result) {},
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}