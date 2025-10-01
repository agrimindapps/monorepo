import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/form_dialog.dart';
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
    
    // Carregar dados do vehicle após inicialização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleData();
    });
  }

  void _loadVehicleData() async {
    if (!mounted) return;

    final vehicleId = _formProvider.vehicleId;
    if (vehicleId.isNotEmpty) {
      final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
      await vehiclesProvider.loadVehicles();
      final vehicle = await vehiclesProvider.getVehicleById(vehicleId);

      if (vehicle != null && mounted) {
        _formProvider.setVehicle(vehicle);
      }
    }
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
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        // Generate subtitle based on vehicle information
        String subtitle = 'Gerencie seus registros de quilometragem';
        if (formProvider.vehicle != null) {
          final vehicle = formProvider.vehicle!;
          final odometer = vehicle.currentOdometer;
          subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
        }

        return FormDialog(
          title: 'Odômetro',
          subtitle: subtitle,
          headerIcon: Icons.speed,
          isLoading: formProvider.isLoading || _isSubmitting,
          confirmButtonText: 'Salvar',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submitFormWithRateLimit,
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
                _buildAdditionalInfoSection(),
              ],
            ),
          ),
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


  Widget _buildBasicInfoSection() {
    return FormSectionHeader(
      title: 'Informações Básicas',
      icon: Icons.event_note,
      child: Column(
        children: [
          _buildOdometerField(),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildRegistrationTypeField(),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          Consumer<OdometerFormProvider>(
            builder: (context, formProvider, child) {
              return CustomRangeDateTimeField(
                value: formProvider.registrationDate,
                onChanged: (newDate) {
                  // Decompor a data e hora para usar os métodos existentes do provider
                  formProvider.setDate(newDate);
                  formProvider.setTime(newDate.hour, newDate.minute);
                },
                label: OdometerConstants.fieldLabels['dataHora']!,
                firstDate: OdometerConstants.minDate,
                lastDate: OdometerConstants.maxDate,
                suffixIcon: OdometerConstants.sectionIcons['dataHora']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionHeader(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      child: Column(
        children: [
          _buildDescriptionField(),
        ],
      ),
    );
  }


  // New specialized field builders
  Widget _buildOdometerField() {
    return Consumer<OdometerFormProvider>(
      builder: (context, formProvider, child) {
        return OdometerField(
          controller: _odometerController,
          label: OdometerConstants.fieldLabels['odometro'],
          hint: '45234',
          currentOdometer: formProvider.vehicle?.currentOdometer,
          lastReading: null, // Será preenchido pelo provider se necessário
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
            fillColor: Colors.white,
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
        return ObservationsField(
          controller: _descriptionController,
          label: OdometerConstants.fieldLabels['descricao'],
          hint: OdometerConstants.fieldHints['descricao'],
          required: false,
          onChanged: (value) {
            // Controller listener will handle the update
          },
        );
      },
    );
  }
  
  // Campo de data/hora removido - agora usa CustomRangeDateTimeField

  // Formatadores não são mais necessários - o OdometerField cuida disso


  // Método de seleção de data removido - agora é tratado pelo CustomRangeDateTimeField

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
              const SizedBox(height: GasometerDesignTokens.spacingSm),
              ...warnings.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${entry.value}'),
                ),
              ),
              const SizedBox(height: GasometerDesignTokens.spacingMd),
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