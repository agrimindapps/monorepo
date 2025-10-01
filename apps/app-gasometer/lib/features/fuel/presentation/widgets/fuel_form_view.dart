import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/centralized_loading_widget.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../../core/widgets/money_form_field.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../core/widgets/receipt_section.dart';
import '../../../../core/widgets/validated_dropdown_field.dart';
import '../../../../core/widgets/validated_form_field.dart';
import '../../../../core/widgets/validated_switch_field.dart';
import '../../../../core/widgets/validated_text_field.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../providers/fuel_form_provider.dart';

class FuelFormView extends StatelessWidget {

  const FuelFormView({
    super.key,
    required this.formProvider,
    this.onSubmit,
  });
  final FuelFormProvider formProvider;
  final VoidCallback? onSubmit;

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
              const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
              _buildAdditionalInfoSection(context, provider),
              const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
              _buildReceiptImageSection(context, provider),
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
          padding: const EdgeInsets.all(GasometerDesignTokens.spacingLg),
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
    return FormSectionHeader(
      title: 'Informações Básicas',
      icon: Icons.calendar_today,
      child: Column(
        children: [
          _buildFuelTypeDropdown(context, provider),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          DateTimeField(
            value: provider.formModel.date,
            onChanged: (newDate) => provider.updateDate(newDate),
            label: FuelConstants.dateLabel,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildFullTankSwitch(context, provider),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context, FuelFormProvider provider) {
    return FormSectionHeader(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      child: Column(
        children: [
          FormFieldRow.standard(
            children: [
              _buildLitersField(context, provider),
              _buildPricePerLiterField(context, provider),
            ],
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildTotalPriceField(context, provider),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildOdometerField(context, provider),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
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

  // Campo de data removido - agora usa DateTimeField

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
      suffix: const Text(
        'L',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      onValidationChanged: (result) {},
    );
  }

  Widget _buildPricePerLiterField(BuildContext context, FuelFormProvider provider) {
    return PriceFormField(
      controller: provider.pricePerLiterController,
      label: FuelConstants.pricePerLiterLabel,
      required: true,
      onChanged: (value) {
        // O provider já está conectado ao controller
      },
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
        fillColor: Colors.grey.shade100,
      ),
      textStyle: TextStyle(
        fontWeight: GasometerDesignTokens.fontWeightBold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildOdometerField(BuildContext context, FuelFormProvider provider) {
    final vehicle = provider.formModel.vehicle;

    return OdometerField(
      controller: provider.odometerController,
      label: FuelConstants.odometerLabel,
      hint: FuelConstants.odometerPlaceholder,
      currentOdometer: vehicle?.currentOdometer,
      lastReading: provider.lastOdometerReading,
      onChanged: (value) {
        // O provider já está conectado ao controller
        // Não precisamos fazer nada aqui
      },
    );
  }


  Widget _buildNotesField(BuildContext context, FuelFormProvider provider) {
    return ObservationsField(
      controller: provider.notesController,
      label: FuelConstants.notesLabel,
      hint: FuelConstants.notesHint,
      required: false,
      onChanged: (value) {
        // O provider já está conectado ao controller
      },
    );
  }

  // Método de seleção de data removido - agora é tratado pelo DateTimeField

  Widget _buildReceiptImageSection(BuildContext context, FuelFormProvider provider) {
    return OptionalReceiptSection(
      imagePath: provider.receiptImagePath,
      hasImage: provider.hasReceiptImage,
      isUploading: provider.isUploadingImage,
      uploadError: provider.imageUploadError,
      onCameraSelected: () => provider.captureReceiptImage(),
      onGallerySelected: () => provider.selectReceiptImageFromGallery(),
      onImageRemoved: () => provider.removeReceiptImage(),
      title: 'Comprovante',
      description: 'Anexe uma foto do comprovante de abastecimento (opcional)',
    );
  }



}