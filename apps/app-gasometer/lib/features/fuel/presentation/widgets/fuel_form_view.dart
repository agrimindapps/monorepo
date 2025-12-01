import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
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
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../providers/fuel_form_notifier.dart';

class FuelFormView extends ConsumerWidget {
  const FuelFormView({super.key, required this.vehicleId, this.onSubmit});
  final String vehicleId;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));

    if (!state.isInitialized) {
      return const CentralizedLoadingWidget(
        message: FuelConstants.loadingFormMessage,
      );
    }

    final model = state.formModel;
    final vehicle = model.vehicle;

    if (vehicle == null) {
      return _buildNoVehicleView(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFuelInfoSection(context, ref),
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildAdditionalInfoSection(context, ref),
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildReceiptImageSection(context, ref),
        ],
      ),
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

  Widget _buildFuelInfoSection(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);

    return FormSectionHeader(
      title: 'Informações Básicas',
      icon: Icons.calendar_today,
      child: Column(
        children: [
          _buildFuelTypeDropdown(context, ref),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          DateTimeField(
            value: state.formModel.date,
            onChanged: (newDate) => notifier.updateDate(newDate),
            label: FuelConstants.dateLabel,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildFullTankSwitch(context, ref),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context, WidgetRef ref) {
    return FormSectionHeader(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      child: Column(
        children: [
          FormFieldRow.standard(
            children: [
              _buildLitersField(context, ref),
              _buildPricePerLiterField(context, ref),
            ],
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildTotalPriceField(context, ref),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildOdometerField(context, ref),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildNotesField(context, ref),
        ],
      ),
    );
  }

  Widget _buildFuelTypeDropdown(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);
    final vehicle = state.formModel.vehicle!;
    final supportedFuels = vehicle.supportedFuels;

    // Se o veículo suporta apenas 1 combustível, bloquear o campo
    final hasOnlyOneFuel = supportedFuels.length == 1;

    return ValidatedDropdownField<FuelType>(
      items: supportedFuels
          .map(
            (fuelType) =>
                ValidatedDropdownItem.text(fuelType, fuelType.displayName),
          )
          .toList(),
      value: state.formModel.fuelType,
      label: FuelConstants.fuelTypeLabel,
      hint: hasOnlyOneFuel
          ? supportedFuels.first.displayName
          : 'Selecione o tipo de combustível',
      prefixIcon: Icons.local_gas_station,
      required: true,
      enabled: !hasOnlyOneFuel,
      onChanged: (fuelType) {
        if (fuelType != null) {
          notifier.updateFuelType(fuelType);
        }
      },
      validator: (value) => notifier.validateField('fuelType', value?.name),
    );
  }

  Widget _buildFullTankSwitch(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);

    return ValidatedSwitchField(
      value: state.formModel.fullTank,
      label: FuelConstants.fullTankLabel,
      labelPosition: SwitchLabelPosition.start,
      showValidationIcon: false,
      onChanged: (value) => notifier.updateFullTank(value),
      validator: (value) {
        return null;
      },
    );
  }

  Widget _buildLitersField(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(fuelFormProvider(vehicleId));
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);

    return ValidatedFormField(
      controller: notifier.litersController,
      focusNode: notifier.litersFocusNode,
      label: 'Litros',
      hint: 'Ex: 45.50',
      prefixIcon: Icons.local_gas_station,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validationType: ValidationType.fuelLiters,
      tankCapacity: state.formModel.vehicle?.tankCapacity,
      required: true,
      validateOnChange: false,
      validateOnFocusOut: true,
      decoration: InputDecoration(
        fillColor: theme.colorScheme.surfaceContainerHighest,
        filled: true,
      ),
    );
  }

  Widget _buildPricePerLiterField(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);

    return PriceFormField(
      controller: notifier.pricePerLiterController,
      focusNode: notifier.pricePerLiterFocusNode,
      label: FuelConstants.pricePerLiterLabel,
      required: true,
      onChanged: (value) {},
    );
  }

  Widget _buildTotalPriceField(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));
    final formatter = FuelFormatterService();
    final totalPrice = state.formModel.totalPrice;
    final formattedTotal = totalPrice > 0 ? formatter.formatTotalPrice(totalPrice) : '';

    return ValidatedTextField(
      key: ValueKey('total_price_$formattedTotal'), // Force rebuild when value changes
      controller: TextEditingController(
        text: formattedTotal,
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

  Widget _buildOdometerField(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);
    final vehicle = state.formModel.vehicle;

    return OdometerField(
      controller: notifier.odometerController,
      focusNode: notifier.odometerFocusNode,
      label: FuelConstants.odometerLabel,
      hint: FuelConstants.odometerPlaceholder,
      currentOdometer: vehicle?.currentOdometer,
      lastReading: state.lastOdometerReading,
      onChanged: (value) {},
    );
  }

  Widget _buildNotesField(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);

    return ObservationsField(
      controller: notifier.notesController,
      focusNode: notifier.notesFocusNode,
      label: FuelConstants.notesLabel,
      hint: FuelConstants.notesHint,
      required: false,
      onChanged: (value) {},
    );
  }

  Widget _buildReceiptImageSection(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fuelFormProvider(vehicleId));
    final notifier = ref.read(fuelFormProvider(vehicleId).notifier);

    return OptionalReceiptSection(
      imagePath: state.receiptImagePath,
      hasImage: state.hasReceiptImage,
      isUploading: state.isUploadingImage,
      uploadError: state.imageUploadError,
      onCameraSelected: () => notifier.captureReceiptImage(),
      onGallerySelected: () => notifier.selectReceiptImageFromGallery(),
      onImageRemoved: () => notifier.removeReceiptImage(),
      title: 'Comprovante',
      description: 'Anexe uma foto do comprovante de abastecimento (opcional)',
    );
  }
}
