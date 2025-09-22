import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/interfaces/validation_result.dart';
import '../../../../core/presentation/widgets/validated_datetime_field.dart';
import '../../../../core/presentation/widgets/validated_dropdown_field.dart';
import '../../../../core/presentation/widgets/validated_form_field.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../expenses/presentation/widgets/receipt_image_picker.dart';
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
    return Consumer<MaintenanceFormProvider>(
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
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildServiceDetailsSection(),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildFinancialInfoSection(),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildReceiptImageSection(context, provider),
        SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildNextServiceDate(),
      ],
    );
  }



  // 1ª Seção: Informações do Serviço (O QUE foi feito e QUANDO)
  Widget _buildServiceInfoSection() {
    return _buildSectionWithoutPadding(
      title: 'Informações do Serviço',
      icon: Icons.build_circle,
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
          SizedBox(height: GasometerDesignTokens.spacingMd),
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
                  Text(type.displayName, style: TextStyle(
                    fontWeight: GasometerDesignTokens.fontWeightMedium,
                    color: GasometerDesignTokens.colorTextPrimary,
                  )),
                  Text(type.description, style: TextStyle(
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
          SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildServiceDateTimeField(context, _formProvider),
        ],
      ),
    );
  }

  // 2ª Seção: Detalhes do Serviço (ONDE foi feito e COMO)
  Widget _buildServiceDetailsSection() {
    return _buildSectionWithoutPadding(
      title: 'Detalhes do Serviço',
      icon: Icons.description_outlined,
      content: Column(
        children: [
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
          SizedBox(height: GasometerDesignTokens.spacingMd),
          ValidatedFormField(
            controller: _formProvider.descriptionController,
            label: 'Descrição dos Serviços',
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
        ],
      ),
    );
  }

  // 3ª Seção: Informações Financeiras e Técnicas (QUANTO custou e quilometragem)
  Widget _buildFinancialInfoSection() {
    return _buildSectionWithoutPadding(
      title: 'Informações Financeiras e Técnicas',
      icon: Icons.monetization_on_outlined,
      content: Column(
        children: [
          ValidatedFormField(
            controller: _formProvider.costController,
            label: 'Custo Total',
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
          SizedBox(height: GasometerDesignTokens.spacingMd),
          ValidatedFormField(
            controller: _formProvider.odometerController,
            label: 'Quilometragem Atual',
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


  Widget _buildReceiptImageSection(BuildContext context, MaintenanceFormProvider provider) {
    return _buildSectionWithoutPadding(
      title: 'Comprovante',
      icon: Icons.receipt,
      content: Column(
        children: [
          ReceiptImagePicker(
            imagePath: provider.receiptImagePath,
            hasImage: provider.hasReceiptImage,
            onImageSelected: () => _showImagePickerOptions(context, provider),
            onImageRemoved: () => provider.removeReceiptImage(),
          ),
          if (provider.isUploadingImage)
            _buildUploadingIndicator(),
          if (provider.imageUploadError != null)
            _buildErrorIndicator(provider.imageUploadError!),
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                GasometerDesignTokens.colorPrimary,
              ),
            ),
          ),
          SizedBox(width: GasometerDesignTokens.spacingSm),
          Text(
            'Processando imagem...',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeSm,
              color: GasometerDesignTokens.colorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(String error) {
    return Padding(
      padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: GasometerDesignTokens.colorError,
          ),
          SizedBox(width: GasometerDesignTokens.spacingSm),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeSm,
                color: GasometerDesignTokens.colorError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, MaintenanceFormProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                subtitle: const Text('Tirar uma nova foto'),
                onTap: () {
                  Navigator.pop(context);
                  provider.captureReceiptImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                subtitle: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  provider.selectReceiptImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // 5ª Seção: Programação de Próxima Manutenção (Opcional)
  Widget _buildNextServiceDate() {
    return _buildSectionWithoutPadding(
      title: 'Programação de Próxima Manutenção',
      icon: Icons.schedule,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defina quando será necessária a próxima manutenção (opcional)',
            style: TextStyle(
              fontSize: GasometerDesignTokens.fontSizeCaption,
              color: GasometerDesignTokens.colorTextSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: GasometerDesignTokens.spacingSm),
          _buildNextServiceDateTimeField(context, _formProvider),
          if (_formProvider.formModel.nextServiceDate != null)
            Padding(
              padding: EdgeInsets.only(top: GasometerDesignTokens.spacingSm),
              child: TextButton.icon(
                onPressed: () => _formProvider.updateNextServiceDate(null),
                icon: Icon(Icons.clear, size: 16),
                label: Text('Remover agendamento'),
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

  Widget _buildServiceDateTimeField(BuildContext context, MaintenanceFormProvider provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectServiceDateTime(context, provider),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Data e Hora do Serviço',
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy').format(provider.formModel.serviceDate),
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
                  TimeOfDay.fromDateTime(provider.formModel.serviceDate).format(context),
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

  Widget _buildNextServiceDateTimeField(BuildContext context, MaintenanceFormProvider provider) {
    final nextDate = provider.formModel.nextServiceDate;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectNextServiceDateTime(context, provider),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Próxima Manutenção (Opcional)',
            suffixIcon: const Icon(
              Icons.schedule,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
            helperText: 'Opcional - ajuda a acompanhar a manutenção preventiva',
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nextDate != null 
                    ? DateFormat('dd/MM/yyyy').format(nextDate)
                    : 'Selecionar data',
                  style: TextStyle(
                    fontSize: 16,
                    color: nextDate != null 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              if (nextDate != null) ...[
                const SizedBox(width: 16),
                Container(
                  height: 20,
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    TimeOfDay.fromDateTime(nextDate).format(context),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectServiceDateTime(BuildContext context, MaintenanceFormProvider provider) async {
    // Select date first
    final date = await showDatePicker(
      context: context,
      initialDate: provider.formModel.serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      // Then select time
      final currentTime = TimeOfDay.fromDateTime(provider.formModel.serviceDate);
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
        provider.updateServiceDate(combinedDateTime);
      }
    }
  }

  Future<void> _selectNextServiceDateTime(BuildContext context, MaintenanceFormProvider provider) async {
    // Select date first
    final currentDate = provider.formModel.nextServiceDate ?? DateTime.now().add(const Duration(days: 30));
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      // Then select time
      final currentTime = provider.formModel.nextServiceDate != null 
        ? TimeOfDay.fromDateTime(provider.formModel.nextServiceDate!)
        : const TimeOfDay(hour: 9, minute: 0); // Default to 9:00 AM
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
        provider.updateNextServiceDate(combinedDateTime);
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
