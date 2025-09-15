import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_widget.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/odometer_entity.dart';
import '../constants/odometer_constants.dart';
import '../providers/odometer_form_provider.dart';
import '../providers/odometer_provider.dart';
import '../services/odometer_validation_service.dart';

class AddOdometerPage extends StatefulWidget {
  const AddOdometerPage({super.key, this.odometer, this.vehicleId});

  final OdometerEntity? odometer;
  final String? vehicleId;

  @override
  State<AddOdometerPage> createState() => _AddOdometerPageState();
}

class _AddOdometerPageState extends State<AddOdometerPage> {
  final _formKey = GlobalKey<FormState>();
  late OdometerFormProvider _formProvider;
  late OdometerValidationService _validationService;
  
  // Controllers for form fields
  final _odometerController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Rate limiting and loading state
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  
  // Listener control flags to ensure proper cleanup
  bool _formProviderListenerAdded = false;
  bool _odometerControllerListenerAdded = false;
  bool _descriptionControllerListenerAdded = false;
  
  // Rate limiting constants
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

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
      _setupFormControllers();
      _populateFields();
      _isInitialized = true;
    }
  }
  
  void _initializeProviders() {
    _formProvider = Provider.of<OdometerFormProvider>(context, listen: false);
    final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
    _validationService = OdometerValidationService(vehiclesProvider);
    
    // Initialize form data
    if (widget.odometer != null) {
      _formProvider.initializeFromOdometer(widget.odometer!);
    } else {
      // Use vehicleId passed from parent page
      final selectedVehicleId = widget.vehicleId ?? '';
      if (selectedVehicleId.isNotEmpty) {
        _formProvider.initializeForNew(selectedVehicleId);
      } else {
        // If no vehicle selected, show error or get from vehicles provider
        debugPrint('Warning: No vehicle selected for new odometer record');
      }
    }
    
    // Notificar mudanças após o build atual completar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Força rebuild após inicialização
        });
      }
    });
  }
  
  void _setupFormControllers() {
    try {
      // Setup listeners for reactive updates with proper error handling
      _formProvider.addListener(_updateControllersFromProvider);
      _formProviderListenerAdded = true;
      
      // Setup controllers with initial values
      _updateControllersFromProvider();
      
      // Add listeners for user input with proper tracking
      _odometerController.addListener(_onOdometerChanged);
      _odometerControllerListenerAdded = true;
      
      _descriptionController.addListener(_onDescriptionChanged);
      _descriptionControllerListenerAdded = true;
      
    } catch (e) {
      // Robust cleanup: only remove listeners that were actually added
      debugPrint('Error setting up form controllers: $e');
      _cleanupListeners();
      rethrow;
    }
  }
  
  /// Safely removes all listeners based on their actual state
  void _cleanupListeners() {
    // Clean up form provider listener if it was added
    if (_formProviderListenerAdded) {
      try {
        _formProvider.removeListener(_updateControllersFromProvider);
      } catch (e) {
        debugPrint('Error removing form provider listener: $e');
      } finally {
        _formProviderListenerAdded = false;
      }
    }
    
    // Clean up odometer controller listener if it was added
    if (_odometerControllerListenerAdded) {
      try {
        _odometerController.removeListener(_onOdometerChanged);
      } catch (e) {
        debugPrint('Error removing odometer controller listener: $e');
      } finally {
        _odometerControllerListenerAdded = false;
      }
    }
    
    // Clean up description controller listener if it was added
    if (_descriptionControllerListenerAdded) {
      try {
        _descriptionController.removeListener(_onDescriptionChanged);
      } catch (e) {
        debugPrint('Error removing description controller listener: $e');
      } finally {
        _descriptionControllerListenerAdded = false;
      }
    }
  }
  
  void _updateControllersFromProvider() {
    // Safety check: only update if the page is still mounted and initialized
    if (!mounted || !_isInitialized) return;
    
    try {
      // Update odometer controller if it's still valid
      final formattedOdometer = _formProvider.formattedOdometer;
      if (_odometerController.text != formattedOdometer) {
        _odometerController.text = formattedOdometer;
      }
      
      // Update description controller if it's still valid
      if (_descriptionController.text != _formProvider.description) {
        _descriptionController.text = _formProvider.description;
      }
      
      // Trigger UI update safely
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error updating controllers from provider: $e');
      // If there's an error, it might mean the controllers are disposed
      // Remove the listener to prevent further errors
      if (_formProviderListenerAdded) {
        _cleanupListeners();
      }
    }
  }
  
  void _onOdometerChanged() {
    // Safety check: only process if mounted and initialized
    if (!mounted || !_isInitialized) return;
    
    try {
      final text = _odometerController.text;
      if (text != _formProvider.formattedOdometer) {
        _formProvider.setOdometerFromString(text);
      }
    } catch (e) {
      debugPrint('Error in odometer changed listener: $e');
      // If there's an error, remove the listener to prevent further issues
      if (_odometerControllerListenerAdded) {
        try {
          _odometerController.removeListener(_onOdometerChanged);
          _odometerControllerListenerAdded = false;
        } catch (removeError) {
          debugPrint('Error removing odometer listener: $removeError');
        }
      }
    }
  }
  
  void _onDescriptionChanged() {
    // Safety check: only process if mounted and initialized
    if (!mounted || !_isInitialized) return;
    
    try {
      final text = _descriptionController.text;
      if (text != _formProvider.description) {
        _formProvider.setDescription(text);
      }
    } catch (e) {
      debugPrint('Error in description changed listener: $e');
      // If there's an error, remove the listener to prevent further issues
      if (_descriptionControllerListenerAdded) {
        try {
          _descriptionController.removeListener(_onDescriptionChanged);
          _descriptionControllerListenerAdded = false;
        } catch (removeError) {
          debugPrint('Error removing description listener: $removeError');
        }
      }
    }
  }

  void _populateFields() {
    // Initial population is handled by the provider setup
    // Controllers are updated via _updateControllersFromProvider
  }


  @override
  void dispose() {
    // Clean up timers to prevent memory leaks
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    
    // Use the robust cleanup method to ensure proper listener removal
    _cleanupListeners();
    
    // Safely dispose controllers
    try {
      _odometerController.dispose();
    } catch (e) {
      debugPrint('Error disposing odometer controller: $e');
    }
    
    try {
      _descriptionController.dispose();
    } catch (e) {
      debugPrint('Error disposing description controller: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return FormDialog(
      title: 'Odômetro',
      subtitle: 'Gerencie seus registros de quilometr...',
      headerIcon: Icons.speed,
      isLoading: context.watch<OdometerFormProvider>().isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitFormWithRateLimit,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildAdditionalInfoSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildBasicInfoSection() {
    return FormSectionWidget(
      title: 'Informações Básicas',
      icon: Icons.event_note,
      children: [
        Column(
          children: [
            _buildOdometerField(),
            SizedBox(height: GasometerDesignTokens.spacingMd),
            _buildRegistrationTypeField(),
            SizedBox(height: GasometerDesignTokens.spacingMd),
            _buildDateTimeField(),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      children: [
        Column(
          children: [
            _buildDescriptionField(),
          ],
        ),
      ],
    );
  }


  // New specialized field builders
  Widget _buildOdometerField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return TextFormField(
          controller: _odometerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: OdometerConstants.fieldLabels['odometro'],
            hintText: '0,00',
            suffixText: OdometerConstants.units['odometro'],
            suffixIcon: formProvider.odometerValue > 0
                ? IconButton(
                    icon: Icon(OdometerConstants.sectionIcons['clear']),
                    onPressed: () => formProvider.clearOdometer(),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          inputFormatters: _getOdometroFormatters(),
          validator: formProvider.validateOdometer,
          onChanged: (value) {
            // Controller listener will handle the update
          },
        );
      },
    );
  }
  
  Widget _buildRegistrationTypeField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return DropdownButtonFormField<OdometerType>(
          value: formProvider.registrationType,
          decoration: InputDecoration(
            labelText: OdometerConstants.fieldLabels['tipoRegistro'],
            hintText: OdometerConstants.fieldHints['tipoRegistro'],
            prefixIcon: Icon(OdometerConstants.sectionIcons['tipoRegistro']),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          items: OdometerType.allTypes.map((type) {
            return DropdownMenuItem<OdometerType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              formProvider.setRegistrationType(type);
            }
          },
          validator: (value) {
            return value == null ? OdometerConstants.validationMessages['tipoObrigatorio'] : null;
          },
        );
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return TextFormField(
          controller: _descriptionController,
          maxLength: OdometerConstants.maxDescriptionLength,
          maxLines: OdometerConstants.descriptionMaxLines,
          decoration: InputDecoration(
            labelText: OdometerConstants.fieldLabels['descricao'],
            hintText: OdometerConstants.fieldHints['descricao'],
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          validator: formProvider.validateDescription,
          onChanged: (value) {
            // Controller listener will handle the update
          },
        );
      },
    );
  }
  
  Widget _buildDateTimeField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDateTime(formProvider),
            child: InputDecorator(
            decoration: InputDecoration(
              labelText: OdometerConstants.fieldLabels['dataHora'],
              suffixIcon: Icon(
                OdometerConstants.sectionIcons['dataHora'],
                size: OdometerConstants.dimensions['calendarIconSize'],
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
                    DateFormat('dd/MM/yyyy').format(formProvider.registrationDate),
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
                    TimeOfDay.fromDateTime(formProvider.registrationDate).format(context),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  // Formatadores de entrada
  List<TextInputFormatter> _getOdometroFormatters() {
    return [
      // Permitir apenas números e vírgula para decimal (consistente com cadastro de veículos)
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      // Limitar a 999999,99 (máximo 6 dígitos inteiros + 2 decimais)
      LengthLimitingTextInputFormatter(9), // 999999,99
      // Formatter personalizado para controlar vírgula decimal
      TextInputFormatter.withFunction((oldValue, newValue) {
        var text = newValue.text;
        var selection = newValue.selection;
        
        // Não permitir vírgula no início
        if (text.startsWith(',')) {
          return oldValue;
        }
        
        // Permitir apenas uma vírgula
        final commaCount = ','.allMatches(text).length;
        if (commaCount > 1) {
          return oldValue;
        }
        
        // Se tem vírgula, limitar a 2 dígitos após a vírgula (consistente com cadastro de veículos)
        if (text.contains(',')) {
          final parts = text.split(',');
          if (parts.length == 2 && parts[1].length > 2) {
            text = '${parts[0]},${parts[1].substring(0, 2)}';
            // Ajustar cursor se o texto foi truncado
            if (selection.baseOffset > text.length) {
              selection = TextSelection.collapsed(offset: text.length);
            }
          }
          // Não permitir vírgula no final se não há dígitos após
          if (parts.length == 2 && parts[1].isEmpty && text.endsWith(',')) {
            // Permitir vírgula temporariamente para que o usuário possa digitar decimal
          }
        }
        
        // Preservar a seleção original se possível, senão posicionar no final
        if (selection.baseOffset <= text.length) {
          return TextEditingValue(
            text: text,
            selection: selection,
          );
        } else {
          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      }),
    ];
  }


  Future<void> _selectDateTime(OdometerFormProvider formProvider) async {
    // Select date first
    final date = await showDatePicker(
      context: context,
      initialDate: formProvider.registrationDate,
      firstDate: OdometerConstants.minDate,
      lastDate: OdometerConstants.maxDate,
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
      // Then select time
      if (mounted) {
        final currentTime = TimeOfDay.fromDateTime(formProvider.registrationDate);
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
          // Update provider instead of local state
          formProvider.setDate(date);
          formProvider.setTime(time.hour, time.minute);
        }
      }
    }
  }

  /// Rate-limited submit method that implements debouncing and prevents rapid clicks
  void _submitFormWithRateLimit() {
    // Prevent multiple rapid clicks
    if (_isSubmitting) {
      debugPrint('Submit already in progress, ignoring duplicate request');
      return;
    }

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    // Set debounce timer to prevent rapid consecutive submissions
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        _submitForm();
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    // Double-check form validation
    if (!_formKey.currentState!.validate()) return;

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
    final odometerProvider = Provider.of<OdometerProvider>(context, listen: false);

    try {
      // Setup timeout protection
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          debugPrint('Submit timeout reached, resetting state');
          setState(() {
            _isSubmitting = false;
          });
          formProvider.setIsLoading(false);
          _showErrorDialog(
            'Timeout',
            'A operação demorou muito para ser concluída. Tente novamente.',
          );
        }
      });

      // Validate form with context
      final validationResult = await _validationService.validateFormWithContext(
        vehicleId: formProvider.vehicleId,
        odometerValue: formProvider.odometerValue,
        registrationDate: formProvider.registrationDate,
        description: formProvider.description,
        type: formProvider.registrationType,
        currentOdometerId: formProvider.isEditing ? formProvider.currentOdometer?.id : null,
      );

      if (!validationResult.isValid) {
        // Show first validation error
        final firstError = validationResult.errors.values.first;
        _showErrorDialog(OdometerConstants.dialogMessages['erro']!, firstError);
        return;
      }

      // Show warnings if any (but allow to continue)
      if (validationResult.hasWarnings) {
        final shouldContinue = await _showWarningDialog(validationResult.warnings);
        if (!shouldContinue) return;
      }

      // Set provider loading state
      formProvider.setIsLoading(true);

      bool success;
      if (formProvider.isEditing) {
        // Update existing odometer
        final updatedOdometer = formProvider.toOdometerEntity(
          id: formProvider.currentOdometer!.id,
          createdAt: formProvider.currentOdometer!.createdAt,
        );
        success = await odometerProvider.updateOdometer(updatedOdometer);
      } else {
        // Create new odometer
        final newOdometer = formProvider.toOdometerEntity();
        success = await odometerProvider.addOdometer(newOdometer);
      }

      if (success) {
        if (mounted) {
          // Close dialog with success result for parent context to handle
          Navigator.of(context).pop({
            'success': true,
            'action': formProvider.isEditing ? 'edit' : 'create',
            'message': formProvider.isEditing 
                ? OdometerConstants.successMessages['edicaoSucesso']!
                : OdometerConstants.successMessages['cadastroSucesso']!,
          });
        }
      } else {
        if (mounted) {
          // Show error in dialog context (before closing)
          final errorMessage = odometerProvider.error.isNotEmpty 
              ? odometerProvider.error 
              : OdometerConstants.validationMessages['erroGenerico']!;
          _showErrorDialog(OdometerConstants.dialogMessages['erro']!, errorMessage);
        }
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (mounted) {
        _showErrorDialog(
          OdometerConstants.dialogMessages['erro']!,
          'Erro inesperado: $e',
        );
      }
    } finally {
      // Clean up timeout timer
      _timeoutTimer?.cancel();
      
      // Reset all loading states
      formProvider.setIsLoading(false);
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
  
  Future<bool> _showWarningDialog(Map<String, String> warnings) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foram encontrados os seguintes avisos:'),
              SizedBox(height: GasometerDesignTokens.spacingSm),
              ...warnings.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${entry.value}'),
                ),
              ),
              SizedBox(height: GasometerDesignTokens.spacingMd),
              const Text('Deseja continuar mesmo assim?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(OdometerConstants.dateTimeLabels['cancelar']!),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(OdometerConstants.dateTimeLabels['confirmar']!),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
}