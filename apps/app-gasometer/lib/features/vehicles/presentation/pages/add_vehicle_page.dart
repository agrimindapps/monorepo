import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/validation/form_validator.dart';
import '../../../../core/widgets/error_header.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/validated_form_field.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_form_notifier.dart';
import '../providers/vehicles_notifier.dart';
import '../widgets/form_sections/vehicle_additional_info_section.dart';
import '../widgets/form_sections/vehicle_basic_info_section.dart';
import '../widgets/form_sections/vehicle_documentation_section.dart';
import '../widgets/form_sections/vehicle_photo_section.dart';
import '../widgets/form_sections/vehicle_technical_section.dart';

class AddVehiclePage extends ConsumerStatefulWidget {
  const AddVehiclePage({super.key, this.vehicle});
  final VehicleEntity? vehicle;

  @override
  ConsumerState<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends ConsumerState<AddVehiclePage>
    with FormErrorHandlerMixin {
  final TextEditingController _observacoesController = TextEditingController();
  late final FormValidator _formValidator;
  final Map<String, GlobalKey> _fieldKeys = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _isInitialized = false;

  void _initializeFormNotifier() {
    if (_isInitialized) return;

    final notifier = ref.read(vehicleFormProvider.notifier);

    if (widget.vehicle != null) {
      notifier.initializeForEdit(widget.vehicle!);
      _observacoesController.text =
          widget.vehicle!.metadata['observacoes'] as String? ?? '';
    }
    _initializeFormValidator();
    _isInitialized = true;
  }

  void _initializeFormValidator() {
    _formValidator = FormValidator();
    final notifier = ref.read(vehicleFormProvider.notifier);
    
    // Initialize keys and focus nodes
    final fields = ['marca', 'modelo', 'ano', 'cor', 'odometro', 'placa', 'chassi', 'renavam', 'observacoes', 'combustivel'];
    for (final field in fields) {
      _fieldKeys[field] = GlobalKey();
      _focusNodes[field] = FocusNode();
    }

    _formValidator.addFields([
      FormFieldConfig(
        fieldId: 'marca',
        controller: notifier.brandController,
        validationType: ValidationType.length,
        required: true,
        minLength: 2,
        maxLength: 50,
        label: 'Marca',
        scrollKey: _fieldKeys['marca'],
        focusNode: _focusNodes['marca'],
      ),
      FormFieldConfig(
        fieldId: 'modelo',
        controller: notifier.modelController,
        validationType: ValidationType.length,
        required: true,
        minLength: 2,
        maxLength: 50,
        label: 'Modelo',
        scrollKey: _fieldKeys['modelo'],
        focusNode: _focusNodes['modelo'],
      ),
      FormFieldConfig(
        fieldId: 'ano',
        controller: notifier.yearController,
        validationType: ValidationType.required,
        required: true,
        label: 'Ano',
        scrollKey: _fieldKeys['ano'],
        focusNode: _focusNodes['ano'],
      ),
      FormFieldConfig(
        fieldId: 'cor',
        controller: notifier.colorController,
        validationType: ValidationType.length,
        required: true,
        minLength: 3,
        maxLength: 30,
        label: 'Cor',
        scrollKey: _fieldKeys['cor'],
        focusNode: _focusNodes['cor'],
      ),
      FormFieldConfig(
        fieldId: 'odometro',
        controller: notifier.odometerController,
        validationType: ValidationType.decimal,
        required: true,
        minValue: 0.0,
        maxValue: 999999.0,
        label: 'Odômetro Atual',
        scrollKey: _fieldKeys['odometro'],
        focusNode: _focusNodes['odometro'],
      ),
      FormFieldConfig(
        fieldId: 'placa',
        controller: notifier.plateController,
        validationType: ValidationType.licensePlate,
        required: true,
        label: 'Placa',
        scrollKey: _fieldKeys['placa'],
        focusNode: _focusNodes['placa'],
      ),
      FormFieldConfig(
        fieldId: 'chassi',
        controller: notifier.chassisController,
        validationType: ValidationType.chassis,
        required: false,
        label: 'Chassi',
        scrollKey: _fieldKeys['chassi'],
        focusNode: _focusNodes['chassi'],
      ),
      FormFieldConfig(
        fieldId: 'renavam',
        controller: notifier.renavamController,
        validationType: ValidationType.renavam,
        required: false,
        label: 'Renavam',
        scrollKey: _fieldKeys['renavam'],
        focusNode: _focusNodes['renavam'],
      ),
      FormFieldConfig(
        fieldId: 'observacoes',
        controller: _observacoesController,
        validationType: ValidationType.length,
        required: false,
        minLength: 0,
        maxLength: 1000,
        label: 'Observações',
        scrollKey: _fieldKeys['observacoes'],
        focusNode: _focusNodes['observacoes'],
      ),
    ]);
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    _formValidator.clear();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _scrollToField(String fieldId) async {
    final key = _fieldKeys[fieldId];
    if (key?.currentContext != null && key!.currentContext!.mounted) {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;
    final authState = ref.watch(authProvider);
    final formState = ref.watch(vehicleFormProvider);
    final notifier = ref.read(vehicleFormProvider.notifier);

    if (authState.status == AuthStatus.authenticating ||
        !authState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _initializeFormNotifier();

    return FormDialog(
      title: 'Veículos',
      subtitle: 'Gerencie seus veículos cadastrados',
      headerIcon: Icons.directions_car,
      isLoading: formState.isLoading,
      confirmButtonText: isEditing ? 'Salvar' : 'Salvar',
      onCancel: () {
        notifier.clearForm();
        _observacoesController.clear();
        Navigator.of(context).pop();
      },
      onConfirm: _submitForm,
      errorMessage: formErrorMessage,
      content: Form(
        key: notifier.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleBasicInfoSection(
              brandController: notifier.brandController,
              modelController: notifier.modelController,
              yearController: notifier.yearController,
              colorController: notifier.colorController,
              brandFieldKey: _fieldKeys['marca']!,
              modelFieldKey: _fieldKeys['modelo']!,
              yearFieldKey: _fieldKeys['ano']!,
              colorFieldKey: _fieldKeys['cor']!,
              brandFocusNode: _focusNodes['marca']!,
              modelFocusNode: _focusNodes['modelo']!,
              yearFocusNode: _focusNodes['ano']!,
              colorFocusNode: _focusNodes['cor']!,
              onYearChanged: (value) {
                notifier.yearController.text = value?.toString() ?? '';
                notifier.markAsChanged();
              },
            ),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            const VehiclePhotoSection(),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            Container(
              key: _fieldKeys['combustivel'],
              child: const VehicleTechnicalSection(),
            ),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            VehicleDocumentationSection(
              odometerController: notifier.odometerController,
              plateController: notifier.plateController,
              chassisController: notifier.chassisController,
              renavamController: notifier.renavamController,
              odometerFieldKey: _fieldKeys['odometro']!,
              plateFieldKey: _fieldKeys['placa']!,
              chassisFieldKey: _fieldKeys['chassi']!,
              renavamFieldKey: _fieldKeys['renavam']!,
              odometerFocusNode: _focusNodes['odometro']!,
              plateFocusNode: _focusNodes['placa']!,
              chassisFocusNode: _focusNodes['chassi']!,
              renavamFocusNode: _focusNodes['renavam']!,
              onOdometerChanged: (_) => setState(() {}),
              onPlateChanged: (_) => setState(() {}),
              onChassisChanged: (_) => setState(() {}),
              onRenavamChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            VehicleAdditionalInfoSection(
              observationsController: _observacoesController,
              observationsFieldKey: _fieldKeys['observacoes']!,
              observationsFocusNode: _focusNodes['observacoes']!,
              onObservationsChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final notifier = ref.read(vehicleFormProvider.notifier);
    final formState = ref.read(vehicleFormProvider);
    clearFormError();
    final validationResult = await _formValidator.validateAll();
    if (formState.selectedFuel.isEmpty) {
      setFormError('Selecione o tipo de combustível');
      await _scrollToField('combustivel');
      return;
    }
    if (!validationResult.isValid) {
      setFormError(validationResult.message);
      await _formValidator.scrollToFirstError();
      return;
    }

    notifier.setLoading(true);

    try {
      if (!mounted) return;
      final vehiclesNotifier = ref.read(vehiclesProvider.notifier);
      final vehicleEntity = notifier.createVehicleEntity();
      final updatedMetadata = Map<String, dynamic>.from(vehicleEntity.metadata);
      updatedMetadata['observacoes'] = _observacoesController.text.trim();

      final updatedVehicleEntity = VehicleEntity(
        id: vehicleEntity.id,
        userId: vehicleEntity.userId,
        name: vehicleEntity.name,
        brand: vehicleEntity.brand,
        model: vehicleEntity.model,
        year: vehicleEntity.year,
        color: vehicleEntity.color,
        licensePlate: vehicleEntity.licensePlate,
        type: vehicleEntity.type,
        supportedFuels: vehicleEntity.supportedFuels,
        currentOdometer: vehicleEntity.currentOdometer,
        createdAt: vehicleEntity.createdAt,
        updatedAt: vehicleEntity.updatedAt,
        metadata: updatedMetadata,
      );
      if (widget.vehicle != null) {
        await vehiclesNotifier.updateVehicle(updatedVehicleEntity);
      } else {
        await vehiclesNotifier.addVehicle(updatedVehicleEntity);
      }

      // Limpar formulário e controller local após sucesso
      if (mounted) {
        notifier.clearForm();
        _observacoesController.clear();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setFormError('Erro ao salvar veículo: $e');
      }
    } finally {
      if (mounted) {
        notifier.setLoading(false);
      }
    }
  }
}
