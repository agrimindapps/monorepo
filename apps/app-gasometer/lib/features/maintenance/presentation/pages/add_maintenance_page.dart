import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/widgets/datetime_field.dart';
import '../../../../core/presentation/widgets/form_section_header.dart';
import '../../../../core/presentation/widgets/money_form_field.dart';
import '../../../../core/presentation/widgets/notes_form_field.dart';
import '../../../../core/presentation/widgets/odometer_field.dart';
import '../../../../core/presentation/widgets/receipt_section.dart';
import '../../../../core/presentation/widgets/validated_dropdown_field.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_form_provider.dart';
import '../providers/maintenance_provider.dart';

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
  late MaintenanceFormProvider _formProvider;
  final Map<String, ValidationResult> _validationResults = {};
  
  // Rate limiting and loading state
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  
  // Rate limiting constants
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  bool get isEditMode => widget.maintenanceToEdit != null;
  
  @override
  void initState() {
    super.initState();
    // Initialization will be done in didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeProviders();
      _isInitialized = true;
    }
  }
  
  void _initializeProviders() async {
    _formProvider = provider.Provider.of<MaintenanceFormProvider>(context, listen: false);
    final authState = ref.read(authNotifierProvider);

    // Set context for dependency injection access
    _formProvider.setContext(context);

    await _formProvider.initialize(
      vehicleId: widget.vehicleId,
      userId: authState.userId,
    );
    
    if (widget.maintenanceToEdit != null) {
      await _loadMaintenanceForEdit(_formProvider);
    }
    
    // Notify changes after current build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Force rebuild after initialization
        });
      }
    });
  }

  Future<void> _loadMaintenanceForEdit(MaintenanceFormProvider prov) async {
    try {
      await prov.initializeWithMaintenance(widget.maintenanceToEdit!);
    } catch (e) {
      throw Exception('Erro ao carregar registro para edição: $e');
    }
  }

  @override
  void dispose() {
    // Clean up timers to prevent memory leaks
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<MaintenanceFormProvider>(
      builder: (context, formProvider, child) {
        // Generate subtitle based on vehicle information
        String subtitle = 'Registre a manutenção do seu veículo';
        if (formProvider.isInitialized && formProvider.formModel.vehicle != null) {
          final vehicle = formProvider.formModel.vehicle!;
          final odometer = vehicle.currentOdometer;
          subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
        }

        return FormDialog(
          title: 'Manutenção',
          subtitle: subtitle,
          headerIcon: Icons.build,
          isLoading: formProvider.isLoading || _isSubmitting,
          confirmButtonText: 'Salvar',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submitFormWithRateLimit,
          content: !formProvider.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : _buildFormContent(formProvider),
        );
      },
    );
  }

  String _formatOdometer(num odometer) {
    return odometer.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildFormContent(MaintenanceFormProvider provider) {
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
        _buildReceiptImageSection(context, provider),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildNextServiceDate(),
      ],
    );
  }



  // 1ª Seção: Informações do Serviço (O QUE foi feito e QUANDO)
  Widget _buildServiceInfoSection() {
    return FormSectionHeader(
      title: 'Informações do Serviço',
      icon: Icons.build_circle,
      child: Column(
        children: [
          ValidatedFormField(
            controller: _formProvider.titleController,
            label: 'Tipo de Manutenção',
            hint: 'Ex: Troca de óleo, Revisão completa...',
            required: true,
            validationType: ValidationType.length,
            minLength: 3,
            maxLengthValidation: 100,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.,\(\)]'))],
            decoration: _formProvider.formModel.errors['title'] != null ? InputDecoration(
              errorText: _formProvider.formModel.errors['title'],
            ) : null,
            onValidationChanged: (result) => _validationResults['type'] = result,
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          ValidatedDropdownField<MaintenanceType>(
            label: 'Categoria',
            value: _formProvider.formModel.type,
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
            onChanged: (value) => _formProvider.updateType(value!),
            required: true,
            hint: 'Selecione a categoria da manutenção',
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          CustomRangeDateTimeField(
            value: _formProvider.formModel.serviceDate,
            onChanged: (newDate) => _formProvider.updateServiceDate(newDate),
            label: 'Data e Hora do Serviço',
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }

  // 2ª Seção: Detalhes do Serviço (ONDE foi feito e COMO)
  Widget _buildServiceDetailsSection() {
    return FormSectionHeader(
      title: 'Detalhes do Serviço',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          LocationField(
            controller: _formProvider.workshopNameController,
            label: 'Oficina/Local',
            hint: 'Nome da oficina ou local da manutenção',
            required: true,
            onChanged: (value) {
              // O provider já está conectado ao controller
            },
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          DescriptionField(
            controller: _formProvider.descriptionController,
            label: 'Descrição dos Serviços',
            hint: 'Descreva os serviços realizados, peças trocadas, etc.',
            required: true,
            onChanged: (value) {
              // O provider já está conectado ao controller
            },
          ),
        ],
      ),
    );
  }

  // 3ª Seção: Informações Financeiras e Técnicas (QUANTO custou e quilometragem)
  Widget _buildFinancialInfoSection() {
    return FormSectionHeader(
      title: 'Informações Financeiras e Técnicas',
      icon: Icons.monetization_on_outlined,
      child: Column(
        children: [
          CostFormField(
            controller: _formProvider.costController,
            label: 'Custo Total',
            required: true,
            onChanged: (value) {
              // O provider já está conectado ao controller
            },
          ),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          OdometerField(
            controller: _formProvider.odometerController,
            label: 'Quilometragem Atual',
            hint: '0,0',
            currentOdometer: _formProvider.formModel.vehicle?.currentOdometer,
            onChanged: (value) => _validationResults['odometer'] = ValidationResult.success(),
          ),
        ],
      ),
    );
  }


  Widget _buildReceiptImageSection(BuildContext context, MaintenanceFormProvider provider) {
    return OptionalReceiptSection(
      imagePath: provider.receiptImagePath,
      hasImage: provider.hasReceiptImage,
      isUploading: provider.isUploadingImage,
      uploadError: provider.imageUploadError,
      onCameraSelected: () => provider.captureReceiptImage(),
      onGallerySelected: () => provider.selectReceiptImageFromGallery(),
      onImageRemoved: () => provider.removeReceiptImage(),
      title: 'Comprovante',
      description: 'Anexe uma foto do comprovante da manutenção (opcional)',
    );
  }




  // 5ª Seção: Programação de Próxima Manutenção (Opcional)
  Widget _buildNextServiceDate() {
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
            value: _formProvider.formModel.nextServiceDate,
            onChanged: (newDate) => _formProvider.updateNextServiceDate(newDate),
            label: 'Próxima Manutenção (Opcional)',
            placeholder: 'Selecionar data',
            suffixIcon: Icons.schedule,
            helperText: 'Opcional - ajuda a acompanhar a manutenção preventiva',
          ),
          if (_formProvider.formModel.nextServiceDate != null)
            Padding(
              padding: const EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
              child: TextButton.icon(
                onPressed: () => _formProvider.updateNextServiceDate(null),
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
    
    // Prevent multiple rapid clicks
    if (_isSubmitting) {
      debugPrint('[MAINTENANCE DEBUG] Submit already in progress, ignoring duplicate request');
      return;
    }

    debugPrint('[MAINTENANCE DEBUG] Starting debounce timer');
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    // Set debounce timer to prevent rapid consecutive submissions
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
    
    // Double-check form validation
    if (!_formProvider.validateForm()) {
      debugPrint('[MAINTENANCE DEBUG] Form validation FAILED - submission aborted');
      return;
    }
    
    debugPrint('[MAINTENANCE DEBUG] Form validation PASSED - proceeding with submission');

    // Prevent concurrent submissions
    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    final formProvider = _formProvider;
    final maintenanceProvider = provider.Provider.of<MaintenanceProvider>(context, listen: false);

    try {
      // Setup timeout protection
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

      // Provider will handle its own loading state

      final maintenanceEntity = formProvider.formModel.toMaintenanceEntity();
      debugPrint('[MAINTENANCE DEBUG] Created maintenance entity: ${maintenanceEntity.toString()}');
      
      bool success;
      if (widget.maintenanceToEdit != null) {
        debugPrint('[MAINTENANCE DEBUG] Calling updateMaintenanceRecord()');
        // Modo edição - preservar ID da entidade original
        final updatedEntity = maintenanceEntity.copyWith(id: widget.maintenanceToEdit!.id);
        success = await maintenanceProvider.updateMaintenanceRecord(updatedEntity);
      } else {
        debugPrint('[MAINTENANCE DEBUG] Calling addMaintenanceRecord()');
        // Modo criação
        success = await maintenanceProvider.addMaintenanceRecord(maintenanceEntity);
      }
      
      debugPrint('[MAINTENANCE DEBUG] Provider operation result: $success');

      if (success) {
        debugPrint('[MAINTENANCE DEBUG] SUCCESS - Closing dialog');
        if (mounted) {
          // Close dialog with success result for parent context to handle
          Navigator.of(context).pop({
            'success': true,
            'action': widget.maintenanceToEdit != null ? 'edit' : 'create',
          });
        }
      } else {
        debugPrint('[MAINTENANCE DEBUG] FAILURE - Showing error dialog');
        debugPrint('[MAINTENANCE DEBUG] Provider error message: ${maintenanceProvider.errorMessage}');
        if (mounted) {
          // Show error in dialog context (before closing)
          final errorMessage = maintenanceProvider.errorMessage?.isNotEmpty == true 
              ? maintenanceProvider.errorMessage! 
              : 'Erro ao salvar manutenção';
          _showErrorDialog('Erro', errorMessage);
        }
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
      // Clean up timeout timer
      _timeoutTimer?.cancel();
      
      // Loading state managed by provider
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

  // Campo de data do serviço removido - agora usa CustomRangeDateTimeField

  // Campo de próxima manutenção removido - agora usa FutureDateTimeField

  // Métodos de seleção de data removidos - agora são tratados pelos DateTimeField components

}
