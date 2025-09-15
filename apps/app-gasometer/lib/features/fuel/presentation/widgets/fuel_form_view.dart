import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/centralized_loading_widget.dart';
import '../../../../core/presentation/widgets/form_section_widget.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/presentation/widgets/validated_text_field.dart';
import '../../../../core/presentation/widgets/validated_dropdown_field.dart';
import '../../../../core/presentation/widgets/validated_switch_field.dart';
import '../../../../core/theme/design_tokens.dart';
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
              SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
              _buildAdditionalInfoSection(context, provider),
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
          padding: EdgeInsets.all(GasometerDesignTokens.spacingLg),
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
    return _buildSectionWithoutPadding(
      title: 'Informações Básicas',
      icon: Icons.calendar_today,
      content: Column(
        children: [
          _buildFuelTypeDropdown(context, provider),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildDateField(context, provider),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildFullTankSwitch(context, provider),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context, FuelFormProvider provider) {
    return _buildSectionWithoutPadding(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      content: Column(
        children: [
          FormFieldRow.standard(
            children: [
              _buildLitersField(context, provider),
              _buildPricePerLiterField(context, provider),
            ],
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildTotalPriceField(context, provider),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildOdometerField(context, provider),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildNotesField(context, provider),
        ],
      ),
    );
  }

  Widget _buildFuelTypeDropdown(BuildContext context, FuelFormProvider provider) {
    final vehicle = provider.formModel.vehicle!;
    final supportedFuels = vehicle.supportedFuels;
    
    return ValidatedDropdownField<FuelType>(
      items: supportedFuels.map((fuelType) => 
        ValidatedDropdownItem.text(fuelType, fuelType.displayName)
      ).toList(),
      value: provider.formModel.fuelType,
      label: FuelConstants.fuelTypeLabel,
      hint: 'Selecione o tipo de combustível',
      prefixIcon: Icons.local_gas_station,
      required: true,
      onChanged: (fuelType) {
        if (fuelType != null) {
          provider.updateFuelType(fuelType);
        }
      },
      validator: (value) => provider.validateField('fuelType', value?.name),
    );
  }

  Widget _buildDateField(BuildContext context, FuelFormProvider provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDateTime(context, provider),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: FuelConstants.dateLabel,
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy').format(provider.formModel.date),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 20,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  TimeOfDay.fromDateTime(provider.formModel.date).format(context),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullTankSwitch(BuildContext context, FuelFormProvider provider) {
    return ValidatedSwitchField(
      value: provider.formModel.fullTank,
      label: FuelConstants.fullTankLabel,
      labelPosition: SwitchLabelPosition.start,
      showValidationIcon: false,
      onChanged: (value) => provider.updateFullTank(value),
      validator: (value) {
        // Optional validation if needed
        return null;
      },
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
    
    return ValidatedTextField(
      controller: TextEditingController(
        text: totalPrice > 0 ? formatter.formatTotalPrice(totalPrice) : '',
      ),
      label: FuelConstants.totalPriceLabel,
      hint: 'Calculado automaticamente',
      prefixIcon: Icons.attach_money,
      enabled: false,
      decoration: InputDecoration(
        prefixText: 'R\$ ',
        filled: true,
        fillColor: GasometerDesignTokens.colorNeutral50,
      ),
      textStyle: TextStyle(
        fontWeight: GasometerDesignTokens.fontWeightBold,
        color: GasometerDesignTokens.colorPrimary,
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

  Future<void> _selectDateTime(BuildContext context, FuelFormProvider provider) async {
    // Select date first
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

    if (date != null && context.mounted) {
      // Then select time
      final currentTime = TimeOfDay.fromDateTime(provider.formModel.date);
      final time = await showTimePicker(
        context: context,
        initialTime: currentTime,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Localizations.override(
              context: context,
              locale: const Locale('pt', 'BR'),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            ),
          );
        },
      );

      if (time != null) {
        // Update provider with combined date and time
        final combinedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        provider.updateDate(combinedDateTime);
      }
    }
  }

  // Helper para criar seções sem padding lateral
  Widget _buildSectionWithoutPadding({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: GasometerDesignTokens.spacingMd),
          child: Row(
            children: [
              Icon(
                icon,
                size: GasometerDesignTokens.iconSizeSm,
                color: GasometerDesignTokens.colorPrimary,
              ),
              SizedBox(width: GasometerDesignTokens.spacingSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeLg,
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                  color: GasometerDesignTokens.colorTextPrimary,
                ),
              ),
            ],
          ),
        ),
        content,
      ],
    );
  }

}