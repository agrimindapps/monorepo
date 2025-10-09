import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../providers/fuel_form_notifier.dart';
import '../providers/fuel_riverpod_notifier.dart';
import '../widgets/fuel_form_view.dart';

class AddFuelPage extends ConsumerStatefulWidget {
  
  const AddFuelPage({
    super.key,
    this.vehicleId,
    this.editFuelRecordId,
  });
  final String? vehicleId;
  final String? editFuelRecordId;

  @override
  ConsumerState<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends ConsumerState<AddFuelPage> {
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  bool get isEditMode => widget.editFuelRecordId != null;

  @override
  void initState() {
    super.initState();
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
    final authState = ref.read(authProvider);
    final vehicleId = widget.vehicleId ?? '';

    if (vehicleId.isEmpty) {
      debugPrint('[FUEL DEBUG] No vehicle selected');
      return;
    }
    final notifier = ref.read(fuelFormNotifierProvider(vehicleId).notifier);
    await notifier.initialize(
      vehicleId: vehicleId,
      userId: authState.userId,
    );

    if (widget.editFuelRecordId != null) {
      await _loadFuelRecordForEdit(vehicleId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  Future<void> _loadFuelRecordForEdit(String vehicleId) async {
    try {
      final fuelNotifier = ref.read(fuelRiverpodProvider.notifier);
      final record = fuelNotifier.getFuelRecordById(widget.editFuelRecordId!);

      if (record != null) {
        final formNotifier = ref.read(fuelFormNotifierProvider(vehicleId).notifier);
        await formNotifier.loadFromFuelRecord(record);
      } else {
        throw Exception('Registro de abastecimento não encontrado');
      }
    } catch (e) {
      throw Exception('Erro ao carregar registro para edição: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleId = widget.vehicleId ?? '';

    if (vehicleId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhum veículo selecionado'),
        ),
      );
    }

    final formState = ref.watch(fuelFormNotifierProvider(vehicleId));
    String subtitle = 'Registre o abastecimento do seu veículo';
    if (formState.isInitialized && formState.formModel.vehicle != null) {
      final vehicle = formState.formModel.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle = '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return FormDialog(
      title: 'Abastecimento',
      subtitle: subtitle,
      headerIcon: Icons.local_gas_station,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submitFormWithRateLimit,
      content: !formState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : FuelFormView(
              vehicleId: vehicleId,
              onSubmit: _submitFormWithRateLimit,
            ),
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
    if (_isSubmitting) {
      debugPrint('[FUEL DEBUG] Submit already in progress, ignoring duplicate request');
      return;
    }

    debugPrint('[FUEL DEBUG] Starting debounce timer');
    _debounceTimer?.cancel();
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

    final vehicleId = widget.vehicleId ?? '';
    if (vehicleId.isEmpty) {
      debugPrint('[FUEL DEBUG] No vehicle selected - submission aborted');
      return;
    }

    final formNotifier = ref.read(fuelFormNotifierProvider(vehicleId).notifier);
    if (!formNotifier.validateForm()) {
      debugPrint('[FUEL DEBUG] Form validation FAILED - submission aborted');
      return;
    }

    debugPrint('[FUEL DEBUG] Form validation PASSED - proceeding with submission');
    if (_isSubmitting) {
      debugPrint('Submit already in progress, aborting duplicate submission');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    final fuelNotifier = ref.read(fuelRiverpodProvider.notifier);

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

      final formState = ref.read(fuelFormNotifierProvider(vehicleId));
      final fuelRecord = formState.formModel.toFuelRecord();
      debugPrint('[FUEL DEBUG] Created fuel record: ${fuelRecord.toString()}');

      bool success;
      if (widget.editFuelRecordId != null) {
        debugPrint('[FUEL DEBUG] Calling updateFuelRecord()');
        success = await fuelNotifier.updateFuelRecord(fuelRecord);
      } else {
        debugPrint('[FUEL DEBUG] Calling addFuelRecord()');
        success = await fuelNotifier.addFuelRecord(fuelRecord);
      }

      debugPrint('[FUEL DEBUG] Provider operation result: $success');

      if (success) {
        debugPrint('[FUEL DEBUG] SUCCESS - Closing dialog');
        if (mounted) {
          Navigator.of(context).pop({
            'success': true,
            'action': widget.editFuelRecordId != null ? 'edit' : 'create',
          });
        }
      } else {
        debugPrint('[FUEL DEBUG] FAILURE - Showing error dialog');
        if (mounted) {
          final fuelState = await ref.read(fuelRiverpodProvider.future);
          final errorMessage = fuelState.errorMessage ?? 'Erro ao salvar abastecimento';
          debugPrint('[FUEL DEBUG] Provider error message: $errorMessage');
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

}
