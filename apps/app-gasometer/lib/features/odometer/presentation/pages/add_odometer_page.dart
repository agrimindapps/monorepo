import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/error_header.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_header.dart';
import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';
import '../../domain/entities/odometer_entity.dart';
import '../constants/odometer_constants.dart';
import '../notifiers/odometer_form_notifier.dart';

class AddOdometerPage extends ConsumerStatefulWidget {
  const AddOdometerPage({super.key, this.odometer, this.vehicleId});

  final OdometerEntity? odometer;
  final String? vehicleId;

  @override
  ConsumerState<AddOdometerPage> createState() => _AddOdometerPageState();
}

class _AddOdometerPageState extends ConsumerState<AddOdometerPage>
    with FormErrorHandlerMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

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
    final userId = authState.userId;
    if (widget.odometer != null) {
      final notifier = ref.read(odometerFormNotifierProvider.notifier);
      await notifier.initializeWithOdometer(widget.odometer!);
    } else {
      final selectedVehicleId = widget.vehicleId ?? '';
      if (selectedVehicleId.isNotEmpty) {
        final notifier = ref.read(odometerFormNotifierProvider.notifier);
        await notifier.initialize(vehicleId: selectedVehicleId, userId: userId);
      } else {
        debugPrint('Warning: No vehicle selected for new odometer record');
      }
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(odometerFormNotifierProvider);
    String subtitle = 'Gerencie seus registros de quilometragem';
    if (formState.hasVehicle) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    return FormDialog(
      title: 'Odômetro',
      subtitle: subtitle,
      headerIcon: Icons.speed,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () {
        final formNotifier = ref.read(odometerFormNotifierProvider.notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      onConfirm: _submitFormWithRateLimit,
      errorMessage: formErrorMessage,
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
          _buildDateTimeField(),
        ],
      ),
    );
  }

  Widget _buildDateTimeField() {
    final formState = ref.watch(odometerFormNotifierProvider);
    final notifier = ref.read(odometerFormNotifierProvider.notifier);

    return CustomRangeDateTimeField(
      value: formState.registrationDate ?? DateTime.now(),
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

  Widget _buildAdditionalInfoSection() {
    return FormSectionHeader(
      title: 'Adicionais',
      icon: Icons.more_horiz,
      child: Column(children: [_buildDescriptionField()]),
    );
  }

  Widget _buildOdometerField() {
    final formState = ref.watch(odometerFormNotifierProvider);
    final notifier = ref.read(odometerFormNotifierProvider.notifier);

    return OdometerField(
      controller: notifier.odometerController,
      label: OdometerConstants.fieldLabels['odometro'],
      hint: '45234',
      currentOdometer: formState.vehicle?.currentOdometer,
      lastReading: null,
      onChanged: (value) {},
    );
  }

  Widget _buildRegistrationTypeField() {
    final formState = ref.watch(odometerFormNotifierProvider);
    final notifier = ref.read(odometerFormNotifierProvider.notifier);

    return DropdownButtonFormField<OdometerType>(
      value: formState.registrationType,
      decoration: InputDecoration(
        labelText: OdometerConstants.fieldLabels['tipoRegistro'],
        hintText: OdometerConstants.fieldHints['tipoRegistro'],
        prefixIcon: Icon(OdometerConstants.sectionIcons['tipoRegistro']),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
          notifier.updateRegistrationType(type);
        }
      },
      validator: (value) {
        return value == null
            ? OdometerConstants.validationMessages['tipoObrigatorio']
            : null;
      },
    );
  }

  Widget _buildDescriptionField() {
    final notifier = ref.read(odometerFormNotifierProvider.notifier);

    return ObservationsField(
      controller: notifier.descriptionController,
      label: OdometerConstants.fieldLabels['descricao'],
      hint: OdometerConstants.fieldHints['descricao'],
      required: false,
      onChanged: (value) {},
    );
  }

  /// Rate-limited submit method that implements debouncing and prevents rapid clicks
  void _submitFormWithRateLimit() {
    if (_isSubmitting) {
      debugPrint('Submit already in progress, ignoring duplicate request');
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && !_isSubmitting) {
        _submitForm();
      }
    });
  }

  /// Internal submit method with enhanced protection and timeout handling
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(odometerFormNotifierProvider.notifier);
    if (!formNotifier.validateForm()) {
      debugPrint('Form validation FAILED');
      return;
    }
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
      if (mounted) {
        setFormError(
          'A funcionalidade de salvar odômetro precisa de um provider Riverpod global (odometerRiverpodProvider).\n\nMigração pendente.',
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
