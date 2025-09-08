import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/widgets/enhanced_dropdown.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../providers/maintenance_form_provider.dart';
import '../providers/maintenance_provider.dart';

class AddMaintenancePage extends StatefulWidget {
  final MaintenanceEntity? maintenanceToEdit;
  final String? vehicleId;

  const AddMaintenancePage({
    super.key,
    this.maintenanceToEdit,
    this.vehicleId,
  });

  @override
  State<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
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
    _formProvider = Provider.of<MaintenanceFormProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Set context for dependency injection access
    _formProvider.setContext(context);

    await _formProvider.initialize(
      vehicleId: widget.vehicleId,
      userId: authProvider.userId,
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

  Future<void> _loadMaintenanceForEdit(MaintenanceFormProvider provider) async {
    try {
      await provider.initializeWithMaintenance(widget.maintenanceToEdit!);
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
    return FormDialog(
      title: 'Manutenção',
      subtitle: 'Registre a manutenção do seu veículo',
      headerIcon: Icons.build,
      isLoading: context.watch<MaintenanceFormProvider>().isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitFormWithRateLimit,
      content: Consumer<MaintenanceFormProvider>(
        builder: (context, formProvider, child) {
          if (!formProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _buildFormContent(formProvider);
        },
      ),
    );
  }

  Widget _buildFormContent(MaintenanceFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBasicInfo(),
        _buildCostAndOdometer(),
        _buildDescription(),
        _buildNextServiceDate(),
      ],
    );
  }



  Widget _buildBasicInfo() {
    return FormSectionWidget.withTitle(
      title: 'Informações Básicas',
      icon: Icons.info_outline,
      showBorder: false,
      content: Column(
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
          FormSpacing.large(),
          ValidatedFormField(
            controller: _formProvider.workshopNameController,
            label: 'Oficina/Local',
            hint: 'Nome da oficina ou local da manutenção',
            required: true,
            validationType: ValidationType.length,
            minLength: 2,
            maxLengthValidation: 100,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\s\-\.,\(\)\/&]'))],
            decoration: _formProvider.formModel.errors['workshopName'] != null ? InputDecoration(
              errorText: _formProvider.formModel.errors['workshopName'],
            ) : null,
            onValidationChanged: (result) => _validationResults['workshop'] = result,
          ),
          FormSpacing.large(),
          FormFieldRow.standard(
            children: [
              /// ✅ UX ENHANCEMENT: Enhanced maintenance type dropdown
              EnhancedDropdown<String>(
                label: 'Tipo',
                value: _formProvider.formModel.type == MaintenanceType.preventive ? 'preventiva' : 'corretiva',
                prefixIcon: Icon(
                  _formProvider.formModel.type == MaintenanceType.preventive 
                    ? Icons.schedule 
                    : Icons.build,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                items: const [
                  EnhancedDropdownItem(
                    value: 'preventiva',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Preventiva', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Manutenção planejada', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  EnhancedDropdownItem(
                    value: 'corretiva',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Corretiva', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('Reparo de problema', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => _formProvider.updateType(
                  value == 'preventiva' ? MaintenanceType.preventive : MaintenanceType.corrective
                ),
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: GasometerDesignTokens.paddingOnly(
                    left: GasometerDesignTokens.spacingLg,
                    right: GasometerDesignTokens.spacingLg,
                    top: GasometerDesignTokens.spacingLg,
                    bottom: GasometerDesignTokens.spacingLg,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: GasometerDesignTokens.spacingSm),
                      Text(
                        '${_formProvider.formModel.serviceDate.day.toString().padLeft(2, '0')}/${_formProvider.formModel.serviceDate.month.toString().padLeft(2, '0')}/${_formProvider.formModel.serviceDate.year}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostAndOdometer() {
    return FormSectionWidget.withTitle(
      title: 'Valores e Medições',
      icon: Icons.monetization_on_outlined,
      showBorder: false,
      content: FormFieldRow.standard(
        children: [
          ValidatedFormField(
            controller: _formProvider.costController,
            label: 'Custo',
            hint: '0,00',
            required: true,
            validationType: ValidationType.money,
            minValue: 0.0,
            maxValue: 999999.99,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              errorText: _formProvider.formModel.errors['cost'],
            ),
            onValidationChanged: (result) => _validationResults['cost'] = result,
          ),
          ValidatedFormField(
            controller: _formProvider.odometerController,
            label: 'Odômetro',
            hint: '0,0',
            required: true,
            validationType: ValidationType.decimal,
            minValue: 0.0,
            maxValue: 9999999.0,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
            decoration: InputDecoration(
              suffixText: 'km',
              errorText: _formProvider.formModel.errors['odometer'],
            ),
            onValidationChanged: (result) => _validationResults['odometer'] = result,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return FormSectionWidget.withTitle(
      title: 'Descrição',
      icon: Icons.description_outlined,
      showBorder: false,
      content: ValidatedFormField(
        controller: _formProvider.descriptionController,
        label: 'Detalhes da manutenção',
        hint: 'Descreva os serviços realizados, peças trocadas, etc.',
        required: true,
        validationType: ValidationType.length,
        minLength: 5,
        maxLengthValidation: 500,
        maxLines: 4,
        maxLength: 500,
        showCharacterCount: true,
        decoration: _formProvider.formModel.errors['description'] != null ? InputDecoration(
          errorText: _formProvider.formModel.errors['description'],
        ) : null,
        onValidationChanged: (result) => _validationResults['description'] = result,
      ),
    );
  }

  Widget _buildNextServiceDate() {
    return FormSectionWidget.withTitle(
      title: 'Próxima Manutenção (Opcional)',
      icon: Icons.notification_important,
      showBorder: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
              onTap: () => _selectNextServiceDate(context),
              child: Container(
                padding: GasometerDesignTokens.paddingOnly(
                      left: GasometerDesignTokens.spacingLg,
                      right: GasometerDesignTokens.spacingLg,
                      top: GasometerDesignTokens.spacingLg,
                      bottom: GasometerDesignTokens.spacingLg,
                    ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusInput),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: GasometerDesignTokens.spacingSm),
                    Text(
                      _formProvider.formModel.nextServiceDate != null
                          ? '${_formProvider.formModel.nextServiceDate!.day.toString().padLeft(2, '0')}/${_formProvider.formModel.nextServiceDate!.month.toString().padLeft(2, '0')}/${_formProvider.formModel.nextServiceDate!.year}'
                          : 'Definir data da próxima manutenção',
                      style: TextStyle(
                        color: _formProvider.formModel.nextServiceDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_formProvider.formModel.nextServiceDate != null)
              Padding(
                padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
                child: TextButton(
                  onPressed: () => _formProvider.updateNextServiceDate(null),
                  child: Text(
                    'Remover data',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    await _formProvider.pickServiceDate(context);
  }

  Future<void> _selectNextServiceDate(BuildContext context) async {
    await _formProvider.pickNextServiceDate(context);
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
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);

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
            'message': widget.maintenanceToEdit != null 
                ? 'Manutenção editada com sucesso!'
                : 'Manutenção adicionada com sucesso!',
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
}
