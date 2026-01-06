import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/crud_form_dialog.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../providers/fuel_form_notifier.dart';
import '../providers/fuel_riverpod_notifier.dart';
import '../widgets/fuel_form_view.dart';

/// Página de formulário de abastecimento com suporte a 3 modos:
/// - Create: Novo registro
/// - View: Visualização (campos readonly)
/// - Edit: Edição de registro existente
class FuelFormPage extends ConsumerStatefulWidget {
  const FuelFormPage({
    super.key,
    this.fuelRecordId,
    this.vehicleId,
    this.initialMode = CrudDialogMode.create,
  });

  /// ID do registro de abastecimento (para view/edit)
  final String? fuelRecordId;

  /// ID do veículo (para create)
  final String? vehicleId;

  /// Modo inicial do formulário
  final CrudDialogMode initialMode;

  @override
  ConsumerState<FuelFormPage> createState() => _FuelFormPageState();
}

class _FuelFormPageState extends ConsumerState<FuelFormPage> {
  late CrudDialogMode _mode;
  bool _isInitialized = false;
  bool _isSubmitting = false;
  String? _formErrorMessage;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  String? _resolvedVehicleId;

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  void _setFormError(String? message) {
    setState(() => _formErrorMessage = message);
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() => _initializeProviders());
    }
  }

  Future<void> _initializeProviders() async {
    final authState = ref.read(authProvider);
    final userId = authState.userId;

    // Se é view/edit, carregar pelo ID do registro
    if (widget.fuelRecordId != null && widget.fuelRecordId!.isNotEmpty) {
      final fuelState = ref.read(fuelRiverpodProvider).value;
      if (fuelState != null) {
        final record = fuelState.fuelRecords.firstWhere(
          (r) => r.id == widget.fuelRecordId,
          orElse: () => throw Exception('Registro não encontrado'),
        );

        _resolvedVehicleId = record.vehicleId;

        final notifier = ref.read(fuelFormProvider(record.vehicleId).notifier);
        await notifier.initialize(vehicleId: record.vehicleId, userId: userId);
        await notifier.loadFromFuelRecord(record);
      }
    }
    // Se é create, inicializar com veículo
    else if (widget.vehicleId != null && widget.vehicleId!.isNotEmpty) {
      _resolvedVehicleId = widget.vehicleId;
      final notifier = ref.read(fuelFormProvider(widget.vehicleId!).notifier);
      notifier.clearForm();
      await notifier.initialize(vehicleId: widget.vehicleId, userId: userId);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleId = _resolvedVehicleId ?? widget.vehicleId ?? '';

    if (vehicleId.isEmpty && _mode == CrudDialogMode.create) {
      return const Center(child: Text('Nenhum veículo selecionado'));
    }

    // Se ainda não inicializou, mostrar loading
    if (vehicleId.isEmpty) {
      return CrudFormDialog(
        mode: _mode,
        title: 'Abastecimento',
        subtitle: 'Carregando...',
        headerIcon: Icons.local_gas_station,
        isLoading: true,
        onCancel: () => Navigator.of(context).pop(),
        content: const Center(child: CircularProgressIndicator()),
      );
    }

    final formState = ref.watch(fuelFormProvider(vehicleId));
    final isReadOnly = _mode == CrudDialogMode.view;

    String subtitle = 'Registre o abastecimento do seu veículo';
    if (formState.isInitialized && formState.formModel.vehicle != null) {
      final vehicle = formState.formModel.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return CrudFormDialog(
      mode: _mode,
      title: 'Abastecimento',
      subtitle: subtitle,
      headerIcon: Icons.local_gas_station,
      isLoading: formState.isLoading,
      isSaving: _isSubmitting,
      canSave: formState.isInitialized && !formState.isLoading,
      errorMessage: _formErrorMessage,
      showDeleteButton: _mode != CrudDialogMode.create,
      onModeChange: (newMode) {
        setState(() => _mode = newMode);
      },
      onSave: _submitFormWithRateLimit,
      onCancel: () {
        final formNotifier = ref.read(fuelFormProvider(vehicleId).notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onDelete: _mode != CrudDialogMode.create ? _handleDelete : null,
      content: !formState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : FuelFormView(
              vehicleId: vehicleId,
              onSubmit: _submitFormWithRateLimit,
              isReadOnly: isReadOnly,
            ),
    );
  }

  String _formatOdometer(num odometer) {
    return odometer.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _submitFormWithRateLimit() {
    if (_isSubmitting) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        _submitForm();
      }
    });
  }

  Future<void> _submitForm() async {
    final vehicleId = _resolvedVehicleId ?? widget.vehicleId ?? '';
    if (vehicleId.isEmpty) return;

    final formNotifier = ref.read(fuelFormProvider(vehicleId).notifier);
    _setFormError(null);

    final (isValid, firstErrorField) = formNotifier.validateForm();

    if (!isValid) {
      if (firstErrorField != null) {
        final formState = ref.read(fuelFormProvider(vehicleId));
        final errorMessage = formState.formModel.errors[firstErrorField];
        _setFormError(errorMessage ?? 'Por favor, corrija os campos destacados');

        final focusNode = formNotifier.fieldFocusNodes[firstErrorField];
        if (focusNode != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              focusNode.requestFocus();
              if (focusNode.context != null) {
                Scrollable.ensureVisible(
                  focusNode.context!,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: 0.2,
                );
              }
            }
          });
        }
      } else {
        _setFormError('Por favor, preencha todos os campos obrigatórios');
      }
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      _timeoutTimer = Timer(_submitTimeout, () {
        if (mounted && _isSubmitting) {
          setState(() => _isSubmitting = false);
          _setFormError('A operação demorou muito. Tente novamente.');
        }
      });

      final result = await formNotifier.saveFuelRecord();

      if (mounted) {
        result.fold(
          (failure) => _setFormError(failure.message),
          (success) {
            formNotifier.clearForm();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                Navigator.of(context).pop(true);
              }
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _setFormError('Erro inesperado: $e');
      }
    } finally {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final fuelRecordId = widget.fuelRecordId;
    if (fuelRecordId == null || fuelRecordId.isEmpty) return;

    // Fecha o dialog e retorna
    Navigator.of(context).pop();

    // Executa o delete via notifier da lista (com undo)
    await ref.read(fuelRiverpodProvider.notifier).deleteOptimistic(fuelRecordId);
  }
}
