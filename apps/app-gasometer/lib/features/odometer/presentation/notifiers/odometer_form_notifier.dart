import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/input_sanitizer.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/services/odometer_formatter.dart';
import '../../domain/services/odometer_validator.dart';
import 'odometer_form_state.dart';

part 'odometer_form_notifier.g.dart';

/// Notifier Riverpod para gerenciar o estado do formulário de odômetro
///
/// Features:
/// - Gerenciamento de campos de texto com TextEditingControllers
/// - Validação em tempo real com debounce
/// - Sanitização de inputs para segurança
/// - Validação contra o odômetro atual do veículo
/// - Suporte para criação e edição de registros
@riverpod
class OdometerFormNotifier extends _$OdometerFormNotifier {
  // TextEditingControllers gerenciados internamente
  late final TextEditingController odometerController;
  late final TextEditingController descriptionController;

  // Services e use cases injetados via GetIt
  late final GetVehicleById _getVehicleById;

  // Timers de debounce
  Timer? _odometerDebounceTimer;
  Timer? _descriptionDebounceTimer;

  // Debounce duration (ms)
  static const int _odometerDebounceMs = 500;
  static const int _descriptionDebounceMs = 300;

  @override
  OdometerFormState build() {
    // Inicializa controllers
    odometerController = TextEditingController();
    descriptionController = TextEditingController();

    // Inicializa services via GetIt
    _getVehicleById = getIt<GetVehicleById>();

    // Adiciona listeners aos controllers
    _initializeControllers();

    // Cleanup ao descartar
    ref.onDispose(() {
      // Cancela timers
      _odometerDebounceTimer?.cancel();
      _descriptionDebounceTimer?.cancel();

      // Remove listeners
      odometerController.removeListener(_onOdometerChanged);
      descriptionController.removeListener(_onDescriptionChanged);

      // Dispose controllers
      odometerController.dispose();
      descriptionController.dispose();
    });

    return const OdometerFormState();
  }

  // ==================== Initialization ====================

  /// Adiciona listeners aos controllers
  void _initializeControllers() {
    odometerController.addListener(_onOdometerChanged);
    descriptionController.addListener(_onDescriptionChanged);
  }

  /// Inicializa formulário para novo registro
  Future<void> initialize({
    required String vehicleId,
    required String userId,
  }) async {
    if (vehicleId.isEmpty) {
      state = state.copyWith(
        errorMessage: () => 'Nenhum veículo selecionado',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Carrega dados do veículo
      final vehicleResult = await _getVehicleById(GetVehicleByIdParams(vehicleId: vehicleId));

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = OdometerFormState.initial(
            vehicleId: vehicleId,
            userId: userId,
          ).copyWith(
            vehicle: vehicle,
            odometerValue: vehicle.currentOdometer,
            isLoading: false,
          );

          _updateTextControllers();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao inicializar formulário: $e',
      );
    }
  }

  /// Inicializa com odômetro existente para edição
  Future<void> initializeWithOdometer(OdometerEntity odometer) async {
    state = state.copyWith(isLoading: true);

    try {
      // Carrega dados do veículo
      final vehicleResult = await _getVehicleById(GetVehicleByIdParams(vehicleId: odometer.vehicleId));

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = OdometerFormState.fromOdometer(odometer).copyWith(
            vehicle: vehicle,
            isLoading: false,
          );

          _updateTextControllers();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao carregar odômetro: $e',
      );
    }
  }

  /// Atualiza controllers com valores do estado
  void _updateTextControllers() {
    odometerController.text =
        state.odometerValue > 0
            ? OdometerFormatter.formatOdometer(state.odometerValue)
            : '';

    descriptionController.text = state.description;
  }

  // ==================== Field Change Handlers ====================

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: _odometerDebounceMs),
      () {
        final value = OdometerFormatter.parseOdometer(odometerController.text);

        state = state.copyWith(
          odometerValue: value,
          hasChanges: true,
        ).clearFieldError('odometerValue');

        // Valida contra o odômetro atual do veículo
        if (state.hasVehicle && value > 0) {
          final validationResult = OdometerValidator.validateOdometerWithVehicle(
            value,
            state.vehicle!,
          );

          if (!validationResult.isValid && validationResult.errorMessage != null) {
            state = state.setFieldError('odometerValue', validationResult.errorMessage!);
          }
        }
      },
    );
  }

  void _onDescriptionChanged() {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: _descriptionDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitizeDescription(descriptionController.text);

        state = state.copyWith(
          description: sanitized,
          hasChanges: true,
        ).clearFieldError('description');
      },
    );
  }

  // ==================== UI Actions ====================

  /// Atualiza tipo de registro
  void updateRegistrationType(OdometerType registrationType) {
    if (state.registrationType == registrationType) return;

    state = state.copyWith(
      registrationType: registrationType,
      hasChanges: true,
    ).clearFieldError('registrationType');
  }

  /// Atualiza data de registro
  void updateRegistrationDate(DateTime date) {
    if (state.registrationDate == date) return;

    state = state.copyWith(
      registrationDate: date,
      hasChanges: true,
    ).clearFieldError('registrationDate');
  }

  /// Atualiza apenas a data (mantém hora)
  void setDate(DateTime date) {
    final currentTime = TimeOfDay.fromDateTime(state.registrationDate ?? DateTime.now());
    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      currentTime.hour,
      currentTime.minute,
    );
    updateRegistrationDate(newDateTime);
  }

  /// Atualiza apenas a hora (mantém data)
  void setTime(int hour, int minute) {
    final currentDate = state.registrationDate ?? DateTime.now();
    final newDateTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      hour,
      minute,
    );
    updateRegistrationDate(newDateTime);
  }

  /// Limpa mensagem de erro
  void clearError() {
    state = state.clearError();
  }

  // ==================== Form Validation ====================

  /// Valida campo específico (para TextFormField)
  String? validateField(String field, String? value) {
    switch (field) {
      case 'odometerValue':
        return OdometerValidator.validateOdometer(value);
      case 'description':
        return OdometerValidator.validateDescription(value);
      default:
        return null;
    }
  }

  /// Valida formulário completo
  bool validateForm() {
    final result = OdometerValidator.validateForSubmission(
      vehicleId: state.vehicleId,
      odometerText: odometerController.text,
      registrationDate: state.registrationDate ?? DateTime.now(),
      description: descriptionController.text,
      type: state.registrationType,
    );

    state = state.copyWith(fieldErrors: result.errors);

    return result.isValid;
  }

  /// Valida odômetro contra veículo
  OdometerValidationResult? validateOdometerWithVehicle() {
    if (!state.hasVehicle) return null;

    return OdometerValidator.validateOdometerWithVehicle(
      state.odometerValue,
      state.vehicle!,
    );
  }

  // ==================== Date/Time Pickers ====================

  /// Abre picker de data
  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.registrationDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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

    if (date != null) {
      setDate(date);
    }
  }

  /// Abre picker de hora
  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(state.registrationDate ?? DateTime.now()),
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
      setTime(time.hour, time.minute);
    }
  }

  // ==================== Form Actions ====================

  /// Limpa formulário
  void clearForm() {
    odometerController.clear();
    descriptionController.clear();

    state = OdometerFormState.initial(
      vehicleId: state.vehicleId,
      userId: state.userId,
    ).copyWith(
      vehicle: state.vehicle,
    );
  }

  /// Reseta formulário
  void resetForm() {
    clearForm();
    state = state.copyWith(
      hasChanges: false,
      fieldErrors: const {},
      errorMessage: () => null,
    );
  }

  // ==================== Data Conversion ====================

  /// Cria OdometerEntity a partir do estado atual do formulário
  OdometerEntity toOdometerEntity({
    String? id,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();

    // Sanitização final antes da persistência
    final sanitizedDescription = InputSanitizer.sanitizeDescription(state.description);

    return OdometerEntity(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      vehicleId: state.vehicleId,
      userId: state.userId,
      value: state.odometerValue,
      registrationDate: state.registrationDate ?? now,
      description: sanitizedDescription,
      type: state.registrationType,
      createdAt: createdAt ?? now,
      updatedAt: now,
      metadata: const {
        'source': 'mobile_app',
        'version': '1.0.0',
      },
    );
  }

  // ==================== Utility Methods ====================

  /// Limpa o valor do odômetro
  void clearOdometer() {
    odometerController.clear();
    state = state.copyWith(
      odometerValue: 0.0,
      hasChanges: true,
    ).clearFieldError('odometerValue');
  }

  /// Obtém tipos de registro disponíveis
  List<OdometerType> get availableTypes => OdometerType.allTypes;

  /// Obtém nomes de exibição dos tipos
  List<String> get typeDisplayNames => OdometerType.displayNames;

  /// Informação de debug
  @override
  String toString() {
    return 'OdometerFormNotifier('
        'vehicleId: ${state.vehicleId}, '
        'odometerValue: ${state.odometerValue}, '
        'type: ${state.registrationType}, '
        'isLoading: ${state.isLoading}, '
        'hasErrors: ${state.hasErrors}'
        ')';
  }
}
