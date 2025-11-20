import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/error_header.dart';
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
import '../notifiers/maintenance_form_notifier.dart';

class AddMaintenancePage extends ConsumerStatefulWidget {
  const AddMaintenancePage({super.key, this.maintenanceToEdit, this.vehicleId});
  final MaintenanceEntity? maintenanceToEdit;
  final String? vehicleId;

  @override
  ConsumerState<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends ConsumerState<AddMaintenancePage>
    with FormErrorHandlerMixin {
  final Map<String, ValidationResult> _validationResults = {};
  final Map<String, FocusNode> _focusNodes = {};
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
    _focusNodes['title'] = FocusNode();
    _focusNodes['description'] = FocusNode();
    _focusNodes['cost'] = FocusNode();
    _focusNodes['odometer'] = FocusNode();
    _focusNodes['workshopName'] = FocusNode();
    _focusNodes['workshopPhone'] = FocusNode();
    _focusNodes['workshopAddress'] = FocusNode();
    _focusNodes['notes'] = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Use Future.microtask to run async initialization without blocking
      Future.microtask(() => _initializeNotifier());
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
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(maintenanceFormNotifierProvider);
    String subtitle = 'Registre a manutenção do seu veículo';
    if (formState.isInitialized && formState.vehicle != null) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return FormDialog(
      title: 'Manutenção',
      subtitle: subtitle,
      headerIcon: Icons.build,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () {
        final formNotifier = ref.read(maintenanceFormNotifierProvider.notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onConfirm: _submitFormWithRateLimit,
      errorMessage: formErrorMessage,
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
    final theme = Theme.of(context);

    return FormSectionHeader(
      title: 'Informações do Serviço',
      icon: Icons.build_circle,
      child: Column(
        children: [
          ValidatedFormField(
            controller: notifier.titleController,
            focusNode: _focusNodes['title'],
            label: 'Tipo de Manutenção',
            hint: 'Ex: Troca de óleo, Revisão completa...',
            required: true,
            validationType: ValidationType.length,
            minLength: 3,
            maxLengthValidation: 100,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.,\(\)]'),
              ),
            ],
            decoration: formState.fieldErrors['title'] != null
                ? InputDecoration(errorText: formState.fieldErrors['title'])
                : null,
            onValidationChanged: (result) =>
                _validationResults['type'] = result,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          ValidatedDropdownField<MaintenanceType>(
            label: 'Categoria',
            value: formState.type,
            prefixIcon: Icons.category,
            items: MaintenanceType.values
                .map(
                  (type) => ValidatedDropdownItem<MaintenanceType>(
                    value: type,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontWeight: GasometerDesignTokens.fontWeightMedium,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          type.description,
                          style: TextStyle(
                            fontSize: GasometerDesignTokens.fontSizeCaption,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
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
            // LocationField doesn't expose focusNode directly in the wrapper, need to check
            // Wait, LocationField is a wrapper around NotesFormField which has focusNode.
            // But LocationField constructor doesn't accept focusNode?
            // Let's check LocationField again.
            label: 'Oficina/Local',
            hint: 'Nome da oficina ou local da manutenção',
            required: true,
            onChanged: (value) {},
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          DescriptionField(
            controller: notifier.descriptionController,
            focusNode: _focusNodes['description'],
            label: 'Descrição dos Serviços',
            hint: 'Descreva os serviços realizados, peças trocadas, etc.',
            required: true,
            onChanged: (value) {},
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
            focusNode: _focusNodes['cost'],
            label: 'Custo Total',
            required: true,
            onChanged: (value) {},
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          OdometerField(
            controller: notifier.odometerController,
            focusNode: _focusNodes['odometer'],
            label: 'Quilometragem Atual',
            hint: '0,0',
            currentOdometer: formState.vehicle?.currentOdometer,
            onChanged: (value) =>
                _validationResults['odometer'] = ValidationResult.success(),
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
    final theme = Theme.of(context);

    return FormSectionHeader(
      title: 'Programação de Próxima Manutenção',
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defina quando será necessária a próxima manutenção (opcional)',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeCaption,
              color: theme.colorScheme.onSurfaceVariant,
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
              padding: const EdgeInsets.only(
                top: GasometerDesignTokens.spacingSm,
              ),
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
      debugPrint(
        '[MAINTENANCE DEBUG] Submit already in progress, ignoring duplicate request',
      );
      return;
    }

    debugPrint('[MAINTENANCE DEBUG] Starting debounce timer');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        debugPrint(
          '[MAINTENANCE DEBUG] Debounce timer fired, calling _submitForm()',
        );
        _submitForm();
      } else {
        debugPrint(
          '[MAINTENANCE DEBUG] Debounce timer fired but widget unmounted or already submitting',
        );
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    debugPrint(
      '[MAINTENANCE DEBUG] _submitForm() called - Starting validation',
    );

    final notifier = ref.read(maintenanceFormNotifierProvider.notifier);
    clearFormError();

    if (!notifier.validateForm()) {
      debugPrint(
        '[MAINTENANCE DEBUG] Form validation FAILED - submission aborted',
      );
      // Pega o primeiro erro para exibir
      final formState = ref.read(maintenanceFormNotifierProvider);
      if (formState.fieldErrors.isNotEmpty) {
        final firstErrorField = formState.fieldErrors.keys.first;
        _focusNodes[firstErrorField]?.requestFocus();
        setFormError(formState.fieldErrors.values.first);
      } else {
        setFormError('Por favor, corrija os campos destacados');
      }
      return;
    }

    debugPrint(
      '[MAINTENANCE DEBUG] Form validation PASSED - proceeding with submission',
    );
    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          debugPrint('Submit timeout reached, resetting state');
          setState(() {
            _isSubmitting = false;
          });
          setFormError(
            'A operação demorou muito para ser concluída. Tente novamente.',
          );
        }
      });

      // Salva o registro usando o UseCase
      final result = await notifier.saveMaintenanceRecord();

      if (mounted) {
        result.fold(
          (failure) {
            debugPrint('[MAINTENANCE DEBUG] FAILURE - ${failure.message}');
            setFormError(failure.message);
          },
          (success) {
            debugPrint('[MAINTENANCE DEBUG] SUCCESS - Closing dialog');
            // Limpar formulário antes de fechar
            notifier.clearForm();
            Navigator.of(context).pop({
              'success': true,
              'action': widget.maintenanceToEdit != null ? 'edit' : 'create',
            });
          },
        );
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (mounted) {
        setFormError('Erro inesperado: $e');
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
}
