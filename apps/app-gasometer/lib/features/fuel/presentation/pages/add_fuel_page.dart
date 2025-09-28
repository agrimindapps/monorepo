import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/fuel_form_provider.dart';
import '../providers/fuel_provider.dart';
import '../widgets/fuel_form_view.dart';

class AddFuelPage extends StatefulWidget {
  
  const AddFuelPage({
    super.key,
    this.vehicleId,
    this.editFuelRecordId,
  });
  final String? vehicleId;
  final String? editFuelRecordId;

  @override
  State<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends State<AddFuelPage> {
  late FuelFormProvider _formProvider;
  
  // Rate limiting and loading state
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  
  // Rate limiting constants
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  bool get isEditMode => widget.editFuelRecordId != null;

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
    _formProvider = Provider.of<FuelFormProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Set context for dependency injection access
    _formProvider.setContext(context);

    await _formProvider.initialize(
      vehicleId: widget.vehicleId,
      userId: authProvider.userId,
    );
    
    if (widget.editFuelRecordId != null) {
      await _loadFuelRecordForEdit(_formProvider);
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

  Future<void> _loadFuelRecordForEdit(FuelFormProvider provider) async {
    try {
      final fuelProvider = context.read<FuelProvider>();
      // Primeiro garantir que os dados foram carregados
      await fuelProvider.loadAllFuelRecords();
      
      final record = fuelProvider.getFuelRecordById(widget.editFuelRecordId!);
      
      if (record != null) {
        await provider.loadFromFuelRecord(record);
      } else {
        throw Exception('Registro de abastecimento não encontrado');
      }
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
    return Consumer<FuelFormProvider>(
      builder: (context, formProvider, child) {
        // Generate subtitle based on vehicle information
        String subtitle = 'Registre o abastecimento do seu veículo';
        if (formProvider.isInitialized && formProvider.formModel.vehicle != null) {
          final vehicle = formProvider.formModel.vehicle!;
          final odometer = vehicle.currentOdometer;
          subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
        }

        return FormDialog(
          title: 'Abastecimento',
          subtitle: subtitle,
          headerIcon: Icons.local_gas_station,
          isLoading: formProvider.isLoading || _isSubmitting,
          confirmButtonText: 'Salvar',
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _submitFormWithRateLimit,
          content: !formProvider.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : FuelFormView(
                  formProvider: formProvider,
                  onSubmit: _submitFormWithRateLimit,
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

  /// Rate-limited submit method that implements debouncing and prevents rapid clicks
  void _submitFormWithRateLimit() {
    debugPrint('[FUEL DEBUG] Submit button clicked - Rate limit check');
    
    // Prevent multiple rapid clicks
    if (_isSubmitting) {
      debugPrint('[FUEL DEBUG] Submit already in progress, ignoring duplicate request');
      return;
    }

    debugPrint('[FUEL DEBUG] Starting debounce timer');
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    // Set debounce timer to prevent rapid consecutive submissions
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        debugPrint('[FUEL DEBUG] Debounce timer fired, calling _submitForm()');
        _submitForm();
      } else {
        debugPrint('[FUEL DEBUG] Debounce timer fired but widget unmounted or already submitting');
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    debugPrint('[FUEL DEBUG] _submitForm() called - Starting validation');
    
    // Double-check form validation
    if (!_formProvider.validateForm()) {
      debugPrint('[FUEL DEBUG] Form validation FAILED - submission aborted');
      return;
    }
    
    debugPrint('[FUEL DEBUG] Form validation PASSED - proceeding with submission');

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
    final fuelProvider = Provider.of<FuelProvider>(context, listen: false);

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

      final fuelRecord = formProvider.formModel.toFuelRecord();
      debugPrint('[FUEL DEBUG] Created fuel record: ${fuelRecord.toString()}');
      
      bool success;
      if (widget.editFuelRecordId != null) {
        debugPrint('[FUEL DEBUG] Calling updateFuelRecord()');
        success = await fuelProvider.updateFuelRecord(fuelRecord);
      } else {
        debugPrint('[FUEL DEBUG] Calling addFuelRecord()');
        success = await fuelProvider.addFuelRecord(fuelRecord);
      }
      
      debugPrint('[FUEL DEBUG] Provider operation result: $success');

      if (success) {
        debugPrint('[FUEL DEBUG] SUCCESS - Closing dialog');
        if (mounted) {
          // Close dialog with success result for parent context to handle
          Navigator.of(context).pop({
            'success': true,
            'action': widget.editFuelRecordId != null ? 'edit' : 'create',
          });
        }
      } else {
        debugPrint('[FUEL DEBUG] FAILURE - Showing error dialog');
        debugPrint('[FUEL DEBUG] Provider error message: ${fuelProvider.errorMessage}');
        if (mounted) {
          // Show error in dialog context (before closing)
          final errorMessage = fuelProvider.errorMessage?.isNotEmpty == true 
              ? fuelProvider.errorMessage! 
              : 'Erro ao salvar abastecimento';
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

}