import 'dart:async';

import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/datetime_field.dart';
import '../../../../core/widgets/error_header.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/form_section_header.dart';
// import '../../../../core/widgets/notes_form_field.dart';
import '../../../../core/widgets/odometer_field.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
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
  final Map<String, FocusNode> _focusNodes = {};
  bool _isInitialized = false;
  bool _isSubmitting = false;
  Timer? _debounceTimer;
  Timer? _timeoutTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _submitTimeout = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _focusNodes['odometer'] = FocusNode();
    _focusNodes['registrationType'] = FocusNode();
    _focusNodes['description'] = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Use Future.microtask to run async initialization without blocking
      Future.microtask(() => _initializeProviders());
    }
  }

  Future<void> _initializeProviders() async {
    final authState = ref.read(authProvider);
    final userId = authState.userId;
    if (widget.odometer != null) {
      final notifier = ref.read(odometerFormProvider.notifier);
      await notifier.initializeWithOdometer(widget.odometer!);
    } else {
      final selectedVehicleId = widget.vehicleId ?? '';
      debugPrint(
        'Initializing odometer form with vehicleId: "$selectedVehicleId"',
      );
      if (selectedVehicleId.isNotEmpty) {
        final notifier = ref.read(odometerFormProvider.notifier);
        // Limpar o formulário antes de inicializar com novo veículo
        notifier.clearForm();
        await notifier.initialize(vehicleId: selectedVehicleId, userId: userId);
        debugPrint(
          'Odometer form initialized successfully with vehicleId: $selectedVehicleId',
        );
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
    for (final node in _focusNodes.values) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(odometerFormProvider);
    String subtitle = 'Gerencie seus registros de quilometragem';
    if (formState.hasVehicle) {
      final vehicle = formState.vehicle!;
      final odometer = vehicle.currentOdometer;
      subtitle =
          '${vehicle.brand} ${vehicle.model} • ${_formatOdometer(odometer)} km';
    }

    // Se não há vehicleId passado, mostrar seletor de veículo
    if (widget.vehicleId == null || widget.vehicleId!.isEmpty) {
      return FormDialog(
        title: 'Selecionar Veículo',
        subtitle: 'Escolha o veículo para registrar a leitura do odômetro',
        headerIcon: Icons.directions_car,
        confirmButtonText: 'Continuar',
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          final selectedVehicleId = ref
              .read(odometerFormProvider)
              .vehicleId;
          if (selectedVehicleId.isNotEmpty) {
            // Reabrir o formulário com o veículo selecionado
            Navigator.of(context).pop();
            showDialog<bool>(
              context: context,
              builder: (context) =>
                  AddOdometerPage(vehicleId: selectedVehicleId),
            );
          }
        },
        content: _buildVehicleSelector(),
      );
    }

    return FormDialog(
      title: 'Odômetro',
      subtitle: subtitle,
      headerIcon: Icons.speed,
      isLoading: formState.isLoading || _isSubmitting,
      confirmButtonText: 'Salvar',
      onCancel: () {
        final formNotifier = ref.read(odometerFormProvider.notifier);
        formNotifier.clearForm();
        Navigator.of(context).pop();
      },
      // Só permite confirmar se tiver veículo carregado
      onConfirm: formState.hasVehicle && !formState.isLoading
          ? _submitFormWithRateLimit
          : null,
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

  Widget _buildVehicleSelector() {
    return EnhancedVehicleSelector(
      selectedVehicleId: null, // Nenhum veículo selecionado inicialmente
      onVehicleChanged: (String? vehicleId) {
        if (vehicleId != null && vehicleId.isNotEmpty) {
          // Reabrir o formulário com o veículo selecionado
          Navigator.of(context).pop();
          showDialog<bool>(
            context: context,
            builder: (context) => AddOdometerPage(vehicleId: vehicleId),
          );
        }
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
          _buildDateTimeField(),
        ],
      ),
    );
  }

  Widget _buildDateTimeField() {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);

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
      child: Column(children: [
        // _buildDescriptionField()
      ]),
    );
  }

  Widget _buildOdometerField() {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);

    return OdometerField(
      controller: notifier.odometerController,
      focusNode: _focusNodes['odometer'],
      label: OdometerConstants.fieldLabels['odometro'],
      hint: '45234',
      currentOdometer: formState.vehicle?.currentOdometer,
      lastReading: null,
      onChanged: (value) {},
      // Integra erros do estado do formulário
      additionalValidator: (value) {
        return formState.getFieldError('odometerValue');
      },
    );
  }

  Widget _buildRegistrationTypeField() {
    final formState = ref.watch(odometerFormProvider);
    final notifier = ref.read(odometerFormProvider.notifier);

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
        // Mostra erro do estado se existir
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
        // Primeiro verifica erro do estado
        final stateError = formState.getFieldError('registrationType');
        if (stateError != null) return stateError;

        // Depois validação local
        return value == null
            ? OdometerConstants.validationMessages['tipoObrigatorio']
            : null;
      },
    );
  }

  // Widget _buildDescriptionField() {
  //   final notifier = ref.read(odometerFormProvider.notifier);
  //
  //   return ObservationsField(
  //     controller: notifier.descriptionController,
  //     focusNode: _focusNodes['description'],
  //     label: OdometerConstants.fieldLabels['descricao'],
  //     hint: OdometerConstants.fieldHints['descricao'],
  //     required: false,
  //     onChanged: (value) {},
  //   );
  // }

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
    if (!_formKey.currentState!.validate()) {
      // Se a validação do Form falhar, o Flutter já foca no primeiro erro automaticamente se os FocusNodes estiverem configurados corretamente.
      // Mas podemos forçar se necessário.
      return;
    }

    final formNotifier = ref.read(odometerFormProvider.notifier);
    if (!formNotifier.validateForm()) {
      debugPrint('Form validation FAILED');
      final formState = ref.read(odometerFormProvider);
      if (formState.fieldErrors.isNotEmpty) {
        // Mapeamento de erros do estado para chaves de focus node
        // OdometerFormNotifier usa chaves como 'odometerValue', 'registrationType', 'description'
        // Precisamos mapear se diferirem.
        // 'odometerValue' -> 'odometer'
        String? focusKey;
        final firstErrorKey = formState.fieldErrors.keys.first;
        if (firstErrorKey == 'odometerValue') {
          focusKey = 'odometer';
        } else if (firstErrorKey == 'registrationType') {
          focusKey = 'registrationType';
        } else if (firstErrorKey == 'description') {
          focusKey = 'description';
        }
        
        if (focusKey != null) {
          _focusNodes[focusKey]?.requestFocus();
        }
        setFormError(formState.fieldErrors.values.first);
      }
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

      // Salva o registro de odômetro
      final result = await formNotifier.saveOdometerReading();

      if (mounted) {
        result.fold(
          (failure) {
            setFormError(failure.message);
          },
          (success) {
            // Sucesso - fecha o dialog
            Navigator.of(context).pop(true);
          },
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
