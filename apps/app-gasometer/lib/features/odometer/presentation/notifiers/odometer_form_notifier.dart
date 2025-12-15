import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/validation/input_sanitizer.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../../vehicles/presentation/providers/vehicle_services_providers.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/services/odometer_formatter.dart';
import '../../domain/services/odometer_validator.dart';
import '../../domain/usecases/add_odometer_reading.dart';
import '../../domain/usecases/update_odometer_reading.dart';
import '../providers/odometer_providers.dart';
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
  late final TextEditingController odometerController;
  late final TextEditingController descriptionController;
  late final GetVehicleById _getVehicleById;
  late final AddOdometerReadingUseCase _addOdometerReading;
  late final UpdateOdometerReadingUseCase _updateOdometerReading;
  
  Timer? _odometerDebounceTimer;
  Timer? _descriptionDebounceTimer;
  static const int _odometerDebounceMs = 500;
  static const int _descriptionDebounceMs = 300;

  @override
  OdometerFormState build() {
    odometerController = TextEditingController();
    descriptionController = TextEditingController();
    
    // Inject dependencies via Bridge Providers
    _getVehicleById = ref.watch(getVehicleByIdProvider);
    _addOdometerReading = ref.watch(addOdometerReadingProvider);
    _updateOdometerReading = ref.watch(updateOdometerReadingProvider);
    
    _initializeControllers();
    ref.onDispose(() {
      _odometerDebounceTimer?.cancel();
      _descriptionDebounceTimer?.cancel();
      odometerController.removeListener(_onOdometerChanged);
      descriptionController.removeListener(_onDescriptionChanged);
      odometerController.dispose();
      descriptionController.dispose();
    });

    return const OdometerFormState();
  }

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
      state = state.copyWith(errorMessage: () => 'Nenhum veículo selecionado');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      debugPrint('Fetching vehicle with ID: $vehicleId');
      final vehicleResult = await _getVehicleById(
        GetVehicleByIdParams(vehicleId: vehicleId),
      );

      await vehicleResult.fold(
        (failure) async {
          debugPrint('Failed to fetch vehicle: ${failure.message}');
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          debugPrint(
            'Vehicle fetched successfully: ${vehicle.brand} ${vehicle.model}',
          );
          state =
              OdometerFormState.initial(
                vehicleId: vehicleId,
                userId: userId,
              ).copyWith(
                vehicle: vehicle,
                isLoading: false,
              );

          _updateTextControllers();
        },
      );
    } catch (e) {
      debugPrint('Error initializing odometer form: $e');
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
      final vehicleResult = await _getVehicleById(
        GetVehicleByIdParams(vehicleId: odometer.vehicleId),
      );

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = OdometerFormState.fromOdometer(
            odometer,
          ).copyWith(vehicle: vehicle, isLoading: false);

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
    odometerController.text = state.odometerValue > 0
        ? OdometerFormatter.formatOdometer(state.odometerValue)
        : '';

    descriptionController.text = state.description;
  }

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: _odometerDebounceMs),
      () {
        final value = OdometerFormatter.parseOdometer(odometerController.text);

        state = state
            .copyWith(odometerValue: value, hasChanges: true)
            .clearFieldError('odometerValue');
        if (state.hasVehicle && value > 0) {
          final validationResult =
              OdometerValidator.validateOdometerWithVehicle(
                value,
                state.vehicle!,
              );

          if (!validationResult.isValid &&
              validationResult.errorMessage != null) {
            state = state.setFieldError(
              'odometerValue',
              validationResult.errorMessage!,
            );
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
        final sanitized = InputSanitizer.sanitizeDescription(
          descriptionController.text,
        );

        state = state
            .copyWith(description: sanitized, hasChanges: true)
            .clearFieldError('description');
      },
    );
  }

  /// Atualiza tipo de registro
  void updateRegistrationType(OdometerType registrationType) {
    if (state.registrationType == registrationType) return;

    state = state
        .copyWith(registrationType: registrationType, hasChanges: true)
        .clearFieldError('registrationType');
  }

  /// Atualiza data de registro
  void updateRegistrationDate(DateTime date) {
    if (state.registrationDate == date) return;

    state = state
        .copyWith(registrationDate: date, hasChanges: true)
        .clearFieldError('registrationDate');
  }

  /// Atualiza apenas a data (mantém hora)
  void setDate(DateTime date) {
    final currentTime = TimeOfDay.fromDateTime(
      state.registrationDate ?? DateTime.now(),
    );
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

    // Debug logging for validation failures
    if (!result.isValid) {
      debugPrint('Form validation failed with errors: ${result.errors}');
      debugPrint(
        'Current state - vehicleId: ${state.vehicleId}, odometer: ${odometerController.text}, type: ${state.registrationType}',
      );
    }

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
      initialTime: TimeOfDay.fromDateTime(
        state.registrationDate ?? DateTime.now(),
      ),
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

  /// Limpa formulário
  void clearForm() {
    odometerController.clear();
    descriptionController.clear();

    state = OdometerFormState.initial(
      vehicleId: '', // Limpar completamente o vehicleId
      userId: state.userId,
    ); // Não manter o vehicle anterior
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

  /// Cria OdometerEntity a partir do estado atual do formulário
  OdometerEntity toOdometerEntity({String? id}) {
    final now = DateTime.now();
    final sanitizedDescription = InputSanitizer.sanitizeDescription(
      state.description,
    );

    return OdometerEntity(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      vehicleId: state.vehicleId,
      userId: state.userId,
      value: state.odometerValue,
      registrationDate: state.registrationDate ?? now,
      description: sanitizedDescription,
      type: state.registrationType,
      createdAt: now,
      updatedAt: now,
      metadata: const {'source': 'mobile_app', 'version': '1.0.0'},
    );
  }

  /// Limpa o valor do odômetro
  void clearOdometer() {
    odometerController.clear();
    state = state
        .copyWith(odometerValue: 0.0, hasChanges: true)
        .clearFieldError('odometerValue');
  }

  /// Salva o registro de odômetro (criar ou atualizar)
  Future<Either<Failure, OdometerEntity?>> saveOdometerReading() async {
    try {
      // Valida antes de salvar
      if (!validateForm()) {
        return const Left(ValidationFailure('Formulário inválido'));
      }

      state = state.copyWith(isLoading: true);

      // Cria entidade a partir do formulário
      final odometerEntity = toOdometerEntity(
        id: state.id.isEmpty ? null : state.id,
      );

      // Decide se é criar ou atualizar
      final Either<Failure, OdometerEntity?> result;

      if (state.id.isEmpty) {
        // Criar novo
        result = await _addOdometerReading(odometerEntity);
      } else {
        // Atualizar existente
        result = await _updateOdometerReading(odometerEntity);
      }

      state = state.copyWith(isLoading: false);

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao salvar: $e',
      );
      return Left(UnknownFailure('Erro inesperado: $e'));
    }
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
