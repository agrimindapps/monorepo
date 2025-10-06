import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/money_form_field.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../core/widgets/receipt_section.dart';
import '../../../../core/widgets/validated_dropdown_field.dart';
import '../../../../core/widgets/validated_form_field.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../models/maintenance_form_model.dart';
import '../notifiers/maintenance_form_notifier.dart';
import '../notifiers/maintenances_notifier.dart';

class AddMaintenancePage extends ConsumerStatefulWidget {

  const AddMaintenancePage({
    super.key,
    this.maintenanceToEdit,
    this.vehicleId,
  });
  final MaintenanceEntity? maintenanceToEdit;
  final String? vehicleId;

  @override
  ConsumerState<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends ConsumerState<AddMaintenancePage> {
  final Map<String, ValidationResult> _validationResults = {};
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  bool get isEditMode => widget.maintenanceToEdit != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeNotifier();
      _isInitialized = true;
    }
  }

  Future<void> _initializeNotifier() async {
    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    final authState = ref.read(authProvider);

    await notifier.initialize(
      vehicleId: widget.vehicleId ?? '',
      userId: authState.userId,
    );

    if (widget.maintenanceToEdit != null) {
      await notifier.initializeWithMaintenance(widget.maintenanceToEdit!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(maintenanceFormNotifierProvider);
    String subtitle = 'Registre a manutenção do seu veículo';
    if (formState.isInitialized && formState.vehicle != null) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return FormDialog(
      title: 'Manutenção',
      subtitle: subtitle,
      headerIcon: Icons.build,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitFormWithRateLimit,
      content: !formState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : _buildFormContent(),
    );
  }

  String _formatOdometer(num odometer) {
    return odometer.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildServiceInfoSection(),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildServiceDetailsSection(),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildFinancialInfoSection(),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildReceiptImageSection(),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildNextServiceDate(),
      ],
    );
  }
  Widget _buildServiceInfoSection() {
    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    final formState = ref.watch(maintenanceFormNotifierProvider);
    return FormSectionHeader(
      title: 'Informações do Serviço',
      icon: Icons.build_circle,
      child: Column(
        children: [
          ValidatedFormField(
            controller: notifier.titleController,
            label: 'Tipo de Manutenção',
            hint: 'Ex: Troca de óleo, Revisão completa...',
            required: true,
            validationType: ValidationType.length,
            minLength: 3,
            maxLengthValidation: 100,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.,\(\)]'))],
            decoration: formState.fieldErrors['title'] != null ? InputDecoration(
              errorText: formState.fieldErrors['title'],
            ) : null,
            onValidationChanged: (result) => _validationResults['type'] = result,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          ValidatedDropdownField<MaintenanceType>(
            label: 'Categoria',
            value: formState.type,
            prefixIcon: Icons.category,
            items: MaintenanceType.values.map((type) => ValidatedDropdownItem<MaintenanceType>(
              value: type,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type.displayName, style: const TextStyle(
                    fontWeight: GasometerDesignTokens.fontWeightMedium,
                    color: GasometerDesignTokens.colorTextPrimary,
                  )),
                  Text(type.description, style: const TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeCaption,
                    color: GasometerDesignTokens.colorTextSecondary,
                  )),
                ],
              ),
            )).toList(),
            onChanged: (value) => notifier.updateType(value!),
            required: true,
            hint: 'Selecione a categoria da manutenção',
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          CustomRangeDateTimeField(
            value: formState.serviceDate ?? DateTime.now(),
            onChanged: (newDate) => notifier.updateServiceDate(newDate),
            label: 'Data e Hora do Serviço',
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }
  Widget _buildServiceDetailsSection() {
    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    return FormSectionHeader(
      title: 'Detalhes do Serviço',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          LocationField(
            controller: notifier.workshopNameController,
            label: 'Oficina/Local',
            hint: 'Nome da oficina ou local da manutenção',
            required: true,
            onChanged: (value) {
            },
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          DescriptionField(
            controller: notifier.descriptionController,
            label: 'Descrição dos Serviços',
            hint: 'Descreva os serviços realizados, peças trocadas, etc.',
            required: true,
            onChanged: (value) {
            },
          ),
        ],
      ),
    );
  }
  Widget _buildFinancialInfoSection() {
    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    final formState = ref.watch(maintenanceFormNotifierProvider);
    return FormSectionHeader(
      title: 'Informações Financeiras e Técnicas',
      icon: Icons.monetization_on_outlined,
      child: Column(
        children: [
          CostFormField(
            controller: notifier.costController,
            label: 'Custo Total',
            required: true,
            onChanged: (value) {
            },
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          OdometerField(
            controller: notifier.odometerController,
            label: 'Quilometragem Atual',
            hint: '0,0',
            currentOdometer: formState.vehicle?.currentOdometer,
            onChanged: (value) => _validationResults['odometer'] = ValidationResult.success(),
          ),
        ],
      ),
    );
  }


  Widget _buildReceiptImageSection() {
    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    final formState = ref.watch(maintenanceFormNotifierProvider);
    return OptionalReceiptSection(
      imagePath: formState.receiptImagePath,
      hasImage: formState.hasReceiptImage,
      isUploading: formState.isUploadingImage,
      uploadError: formState.imageUploadError,
      onCameraSelected: () => notifier.captureReceiptImage(),
      onGallerySelected: () => notifier.selectReceiptImageFromGallery(),
      onImageRemoved: () => notifier.removeReceiptImage(),
      title: 'Comprovante',
      description: 'Anexe uma foto do comprovante da manutenção (opcional)',
    );
  }
  Widget _buildNextServiceDate() {
    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    final formState = ref.watch(maintenanceFormNotifierProvider);
    return FormSectionHeader(
      title: 'Programação de Próxima Manutenção',
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Defina quando será necessária a próxima manutenção (opcional)',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeCaption,
              color: GasometerDesignTokens.colorTextSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: GasometerDesignTokens.spacingSm),
          FutureDateTimeField(
            value: formState.nextServiceDate,
            onChanged: (newDate) => notifier.updateNextServiceDate(newDate),
            label: 'Próxima Manutenção (Opcional)',
            placeholder: 'Selecionar data',
            suffixIcon: Icons.schedule,
            helperText: 'Opcional - ajuda a acompanhar a manutenção preventiva',
          ),
          if (formState.nextServiceDate != null)
            Padding(
              padding: const EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
              child: TextButton.icon(
                onPressed: () => notifier.updateNextServiceDate(null),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Remover agendamento'),
                style: TextButton.styleFrom(
                  foregroundColor: GasometerDesignTokens.colorError,
                ),
              ),
            ),
        ],
      ),
    );
  }



  /// Rate-limited submit method that implements debouncing and prevents rapid clicks
  void _submitFormWithRateLimit() {
    debugPrint('[MAINTENANCE DEBUG] Submit button clicked - Rate limit check');
    if (_isSubmitting) {
      debugPrint('[MAINTENANCE DEBUG] Submit already in progress, ignoring duplicate request');
      return;
    }

    debugPrint('[MAINTENANCE DEBUG] Starting debounce timer');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        debugPrint('[MAINTENANCE DEBUG] Debounce timer fired, calling _submitForm()');
        _submitForm();
      } else {
        debugPrint('[MAINTENANCE DEBUG] Debounce timer fired but widget unmounted or already submitting');
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    debugPrint('[MAINTENANCE DEBUG] _submitForm() called - Starting validation');

    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    if (!notifier.validateForm()) {
      debugPrint('[MAINTENANCE DEBUG] Form validation FAILED - submission aborted');
      return;
    }

    debugPrint('[MAINTENANCE DEBUG] Form validation PASSED - proceeding with submission');
    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    final maintenancesNotifier = ref.read(maintenancesNotifierProvider.notifier);

    try {
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          debugPrint('Submit timeout reached, resetting state');
          setState(() {
            _isSubmitting = false;
          });
          _showErrorDialog(
            'Timeout',
            'A operação demorou muito para ser concluída. Tente novamente.',
          );
        }
      });

      final formState = ref.read(maintenanceFormNotifierProvider);
      final List<String> allPhotosPaths = [
        ...formState.photosPaths,
        if (formState.receiptImagePath != null) formState.receiptImagePath!,
      ];
      final MaintenanceEntity tempEntity = MaintenanceEntity(
        id: widget.maintenanceToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: formState.vehicleId,
        userId: formState.userId,
        type: formState.type,
        status: formState.status,
        title: formState.title,
        description: formState.description,
        cost: formState.cost,
        odometer: formState.odometer,
        workshopName: formState.workshopName.isNotEmpty ? formState.workshopName : null,
        workshopPhone: formState.workshopPhone.isNotEmpty ? formState.workshopPhone : null,
        workshopAddress: formState.workshopAddress.isNotEmpty ? formState.workshopAddress : null,
        serviceDate: formState.serviceDate ?? DateTime.now(),
        nextServiceDate: formState.nextServiceDate,
        nextServiceOdometer: formState.nextServiceOdometer,
        photosPaths: allPhotosPaths,
        invoicesPaths: formState.invoicesPaths,
        parts: formState.parts,
        notes: formState.notes.isNotEmpty ? formState.notes : null,
        createdAt: widget.maintenanceToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const {},
      );
      final MaintenanceFormModel formModel = MaintenanceFormModel.fromMaintenanceEntity(tempEntity);

      debugPrint('[MAINTENANCE DEBUG] Created maintenance form model: ${formModel.toString()}');

      bool success;
      if (widget.maintenanceToEdit != null) {
        debugPrint('[MAINTENANCE DEBUG] Calling updateMaintenance()');
        success = await maintenancesNotifier.updateMaintenance(formModel);
      } else {
        debugPrint('[MAINTENANCE DEBUG] Calling addMaintenance()');
        success = await maintenancesNotifier.addMaintenance(formModel);
      }

      debugPrint('[MAINTENANCE DEBUG] Operation result: $success');

      if (success && mounted) {
        debugPrint('[MAINTENANCE DEBUG] SUCCESS - Closing dialog');
        Navigator.of(context).pop({
          'success': true,
          'action': widget.maintenanceToEdit != null ? 'edit' : 'create',
        });
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (mounted) {
        _showErrorDialog(
          'Erro',
          'Erro inesperado: $e',
        );
      }
    } finally {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  /// ✅ REMOVED: Old dropdown method no longer needed with EnhancedDropdown

}
