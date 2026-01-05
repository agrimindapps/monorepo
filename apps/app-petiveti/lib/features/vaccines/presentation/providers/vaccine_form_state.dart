import '../../../animals/domain/entities/animal.dart';
import '../../domain/entities/vaccine.dart';

/// Estado do formulário de vacina
class VaccineFormState {
  const VaccineFormState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isSaving = false,
    this.animal,
    this.vaccine,
    this.name = '',
    this.veterinarian = '',
    this.batch,
    this.manufacturer,
    this.dosage,
    this.notes,
    required this.date,
    this.nextDueDate,
    this.reminderDate,
    this.status = VaccineStatus.scheduled,
    this.isRequired = true,
    this.nameError,
    this.veterinarianError,
    this.dateError,
  });

  final bool isInitialized;
  final bool isLoading;
  final bool isSaving;
  final Animal? animal;
  final Vaccine? vaccine;
  final String name;
  final String veterinarian;
  final String? batch;
  final String? manufacturer;
  final String? dosage;
  final String? notes;
  final DateTime date;
  final DateTime? nextDueDate;
  final DateTime? reminderDate;
  final VaccineStatus status;
  final bool isRequired;
  final String? nameError;
  final String? veterinarianError;
  final String? dateError;

  /// Estado inicial
  factory VaccineFormState.initial() => VaccineFormState(
        date: DateTime.now(),
      );

  /// Se o formulário é válido
  bool get isValid {
    return name.isNotEmpty &&
        veterinarian.isNotEmpty &&
        nameError == null &&
        veterinarianError == null &&
        dateError == null;
  }

  /// Se pode salvar (inicializado, válido, não salvando)
  bool get canSave {
    return isInitialized && isValid && !isSaving && !isLoading;
  }

  VaccineFormState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isSaving,
    Animal? animal,
    Vaccine? vaccine,
    String? name,
    String? veterinarian,
    String? batch,
    String? manufacturer,
    String? dosage,
    String? notes,
    DateTime? date,
    DateTime? nextDueDate,
    DateTime? reminderDate,
    VaccineStatus? status,
    bool? isRequired,
    String? nameError,
    String? veterinarianError,
    String? dateError,
    bool clearErrors = false,
  }) {
    return VaccineFormState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      animal: animal ?? this.animal,
      vaccine: vaccine ?? this.vaccine,
      name: name ?? this.name,
      veterinarian: veterinarian ?? this.veterinarian,
      batch: batch ?? this.batch,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      isRequired: isRequired ?? this.isRequired,
      nameError: clearErrors ? null : (nameError ?? this.nameError),
      veterinarianError: clearErrors ? null : (veterinarianError ?? this.veterinarianError),
      dateError: clearErrors ? null : (dateError ?? this.dateError),
    );
  }
}
