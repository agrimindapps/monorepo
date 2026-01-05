import '../../../animals/domain/entities/animal.dart';
import '../../domain/entities/appointment.dart';

/// Estado do formulário de consulta
class AppointmentFormState {
  const AppointmentFormState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isSaving = false,
    this.animal,
    this.appointment,
    this.veterinarianName = '',
    this.reason = '',
    this.diagnosis,
    this.notes,
    required this.date,
    this.status = AppointmentStatus.scheduled,
    this.cost,
    this.veterinarianNameError,
    this.reasonError,
    this.dateError,
    this.costError,
  });

  final bool isInitialized;
  final bool isLoading;
  final bool isSaving;
  final Animal? animal;
  final Appointment? appointment;
  final String veterinarianName;
  final String reason;
  final String? diagnosis;
  final String? notes;
  final DateTime date;
  final AppointmentStatus status;
  final double? cost;
  final String? veterinarianNameError;
  final String? reasonError;
  final String? dateError;
  final String? costError;

  /// Estado inicial
  factory AppointmentFormState.initial() => AppointmentFormState(
        date: DateTime.now(),
      );

  /// Se o formulário é válido
  bool get isValid {
    return veterinarianName.isNotEmpty &&
        reason.isNotEmpty &&
        veterinarianNameError == null &&
        reasonError == null &&
        dateError == null &&
        costError == null;
  }

  /// Se pode salvar (inicializado, válido, não salvando)
  bool get canSave {
    return isInitialized && isValid && !isSaving && !isLoading;
  }

  AppointmentFormState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isSaving,
    Animal? animal,
    Appointment? appointment,
    String? veterinarianName,
    String? reason,
    String? diagnosis,
    String? notes,
    DateTime? date,
    AppointmentStatus? status,
    double? cost,
    String? veterinarianNameError,
    String? reasonError,
    String? dateError,
    String? costError,
    bool clearErrors = false,
  }) {
    return AppointmentFormState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      animal: animal ?? this.animal,
      appointment: appointment ?? this.appointment,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      veterinarianNameError:
          clearErrors ? null : (veterinarianNameError ?? this.veterinarianNameError),
      reasonError: clearErrors ? null : (reasonError ?? this.reasonError),
      dateError: clearErrors ? null : (dateError ?? this.dateError),
      costError: clearErrors ? null : (costError ?? this.costError),
    );
  }
}
