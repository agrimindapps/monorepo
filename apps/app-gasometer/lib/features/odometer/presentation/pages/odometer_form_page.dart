import 'dart:async';

import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/crud_form_dialog.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../core/widgets/readonly_field.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../domain/entities/odometer_entity.dart';
import '../constants/odometer_constants.dart';
import '../notifiers/odometer_form_notifier.dart';
import '../providers/odometer_notifier.dart';

/// Página de formulário de odômetro com suporte a 3 modos:
/// - Create: Novo registro
/// - View: Visualização (campos readonly)
/// - Edit: Edição de registro existente
class OdometerFormPage extends ConsumerStatefulWidget {
  const OdometerFormPage({
    super.key,
    this.odometerId,
    this.vehicleId,
    this.initialMode = CrudDialogMode.create,
  });

  /// ID do registro de odômetro (para view/edit)
  final String? odometerId;

  /// ID do veículo (para create)
  final String? vehicleId;

  /// Modo inicial do formulário
  final CrudDialogMode initialMode;

  @override
  ConsumerState<OdometerFormPage> createState() => _OdometerFormPageState();
}

class _OdometerFormPageState extends ConsumerState<OdometerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, FocusNode> _focusNodes = {};

  late CrudDialogMode _mode;
  bool _isInitialized = false;
  bool _isSubmitting = false;
  String? _formErrorMessage;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  void _setFormError(String? message) {
    setState(() => _formErrorMessage = message);
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _focusNodes['odometer'] = FocusNode();
    _focusNodes['registrationType'] = FocusNode();
    _focusNodes['description'] = FocusNode();
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

    // Se é view/edit, carregar pelo ID
    if (widget.odometerId != null && widget.odometerId!.isNotEmpty) {
      final odometerState = ref.read(odometerProvider);
      final odometer = odometerState.readings.firstWhere(
        (r) => r.id == widget.odometerId,
        orElse: () => throw Exception('Registro não encontrado'),
      );

      final notifier = ref.read(odometerFormProvider.notifier);
      await notifier.initializeWithOdometer(odometer);
    }
    // Se é create, inicializar com veículo
    else if (widget.vehicleId != null && widget.vehicleId!.isNotEmpty) {
      final notifier = ref.read(odometerFormProvider.notifier);
      notifier.clearForm();
      await notifier.initialize(vehicleId: widget.vehicleId!, userId: userId);
    }

    if (mounted) setState(() {});
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
    final formState = ref.watch(odometerFormProvider);
    final isReadOnly = _mode == CrudDialogMode.view;

    String subtitle = 'Gerencie seus registros de quilometragem';
    if (formState.hasVehicle) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    // Se não há vehicleId e é create, mostrar seletor de veículo
    if (_mode == CrudDialogMode.create &&
        (widget.vehicleId == null || widget.vehicleId!.isEmpty)) {
      return _buildVehicleSelectionDialog();
    }

    return CrudFormDialog(
      mode: _mode,
      title: 'Odômetro',
      subtitle: subtitle,
      headerIcon: Icons.speed,
      isLoading: formState.isLoading,
      isSaving: _isSubmitting,
      canSave: formState.hasVehicle && !formState.isLoading,
      errorMessage: _formErrorMessage,
      showDeleteButton: _mode != CrudDialogMode.create,
      onModeChange: (newMode) {
        setState(() => _mode = newMode);
      },
      onSave: _submitFormWithRateLimit,
      onCancel: () {
        final formNotifier = ref.read(odometerFormProvider.notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onDelete: _mode != CrudDialogMode.create ? _handleDelete : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(isReadOnly),
            const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildAdditionalInfoSection(isReadOnly),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelectionDialog() {
    return CrudFormDialog(
      mode: CrudDialogMode.create,
      title: 'Veículo',
      subtitle: 'Escolha o veículo para registrar a leitura do odômetro',
      headerIcon: Icons.directions_car,
      showDeleteButton: false,
      onCancel: () => Navigator.of(context).pop(),
      content: EnhancedVehicleSelector(
        selectedVehicleId: null,
        onVehicleChanged: (String? vehicleId) {
          if (vehicleId != null && vehicleId.isNotEmpty) {
            Navigator.of(context).pop();
            showDialog<bool>(
              context: context,
              builder: (context) => OdometerFormPage(
                vehicleId: vehicleId,
                initialMode: CrudDialogMode.create,
              ),
            );
          }
        },
      ),
    );
  }

  String _formatOdometer(num odometer) {
    return odometer.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildBasicInfoSection(bool isReadOnly) {
    return FormSectionHeader(
      title: 'Informações Básicas',
      icon: Icons.event_note,
      child: Column(
        children: [
          _buildOdometerField(isReadOnly),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildRegistrationTypeField(isReadOnly),
          const SizedBox(height: GasometerDesignTokens.spacingMd),
          _buildDateTimeField(isReadOnly),
        ],
      ),
    );
  }

  Widget _buildOdometerField(bool isReadOnly) {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);

    if (isReadOnly) {
      return ReadOnlyField(
        label: OdometerConstants.fieldLabels['odometro'] ?? 'Odômetro',
        value: '${_formatOdometer(formState.odometerValue)} km',
        icon: Icons.speed,
      );
    }

    return OdometerField(
      controller: notifier.odometerController,
      focusNode: _focusNodes['odometer'],
      label: OdometerConstants.fieldLabels['odometro'],
      hint: '45234',
      currentOdometer: formState.vehicle?.currentOdometer,
      lastReading: null,
      onChanged: (value) {},
      additionalValidator: (value) {
        return formState.getFieldError('odometerValue');
      },
    );
  }

  Widget _buildRegistrationTypeField(bool isReadOnly) {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);

    if (isReadOnly) {
      return ReadOnlyField(
        label: OdometerConstants.fieldLabels['tipoRegistro'] ?? 'Tipo',
        value: formState.registrationType.displayName,
        icon: OdometerConstants.sectionIcons['tipoRegistro'],
      );
    }

    return DropdownButtonFormField<OdometerType>(
      initialValue: formState.registrationType,
      focusNode: _focusNodes['registrationType'],
      decoration: InputDecoration(
        labelText: OdometerConstants.fieldLabels['tipoRegistro'],
        hintText: OdometerConstants.fieldHints['tipoRegistro'],
        prefixIcon: Icon(OdometerConstants.sectionIcons['tipoRegistro']),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        errorText: formState.getFieldError('registrationType'),
      ),
      items: OdometerType.allTypes.map((type) {
        return DropdownMenuItem<OdometerType>(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (type) {
        if (type != null) {
          notifier.updateRegistrationType(type);
        }
      },
      validator: (value) {
        final stateError = formState.getFieldError('registrationType');
        if (stateError != null) return stateError;
        return value == null
            ? OdometerConstants.validationMessages['tipoObrigatorio']
            : null;
      },
    );
  }

  Widget _buildDateTimeField(bool isReadOnly) {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);
    final dateValue = formState.registrationDate ?? DateTime.now();

    if (isReadOnly) {
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return ReadOnlyField(
        label: OdometerConstants.fieldLabels['dataHora'] ?? 'Data e Hora',
        value: formatter.format(dateValue),
        icon: OdometerConstants.sectionIcons['dataHora'],
      );
    }

    return CustomRangeDateTimeField(
      value: dateValue,
      onChanged: (newDate) {
        notifier.setDate(newDate);
        notifier.setTime(newDate.hour, newDate.minute);
      },
      label: OdometerConstants.fieldLabels['dataHora']!,
      firstDate: OdometerConstants.minDate,
      lastDate: OdometerConstants.maxDate,
      suffixIcon: OdometerConstants.sectionIcons['dataHora']!,
    );
  }

  Widget _buildAdditionalInfoSection(bool isReadOnly) {
    return FormSectionHeader(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      child: Column(children: [_buildDescriptionField(isReadOnly)]),
    );
  }

  Widget _buildDescriptionField(bool isReadOnly) {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);

    if (isReadOnly) {
      return ReadOnlyField(
        label: OdometerConstants.fieldLabels['descricao'] ?? 'Observações',
        value: formState.description.isEmpty
            ? 'Nenhuma observação'
            : formState.description,
        icon: Icons.notes,
      );
    }

    return ObservationsField(
      controller: notifier.descriptionController,
      focusNode: _focusNodes['description'],
      label: OdometerConstants.fieldLabels['descricao'],
      hint: OdometerConstants.fieldHints['descricao'],
      required: false,
      onChanged: (value) {},
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
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(odometerFormProvider.notifier);
    if (!formNotifier.validateForm()) {
      final formState = ref.read(odometerFormProvider);
      if (formState.fieldErrors.isNotEmpty) {
        _setFormError(formState.fieldErrors.values.first);
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

      final result = await formNotifier.saveOdometerReading();

      if (mounted) {
        result.fold(
          (failure) => _setFormError(failure.message),
          (success) => Navigator.of(context).pop(true),
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
    final odometerId = widget.odometerId;
    if (odometerId == null || odometerId.isEmpty) return;

    // Fecha o dialog e retorna indicando que foi deletado
    Navigator.of(context).pop();

    // Executa o delete via notifier da lista (com undo)
    await ref.read(odometerProvider.notifier).deleteOptimistic(odometerId);
  }
}
