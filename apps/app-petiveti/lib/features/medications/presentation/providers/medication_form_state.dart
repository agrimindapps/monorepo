import '../../domain/entities/medication.dart';

class MedicationFormState {
  const MedicationFormState({
    this.medication,
    this.animalId,
    this.name = '',
    this.dosage = '',
    this.frequency = '',
    this.duration = '',
    this.notes = '',
    this.prescribedBy = '',
    this.type = MedicationType.other,
    DateTime? startDate,
    DateTime? endDate,
    this.isLoading = false,
    this.errorMessage,
  })  : startDate = startDate ?? _fallbackStartDate,
        endDate = endDate ?? _fallbackEndDate;

  static final DateTime _fallbackStartDate = DateTime.now();
  static final DateTime _fallbackEndDate = DateTime.now().add(const Duration(days: 7));

  final Medication? medication;
  final String? animalId;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;
  final String prescribedBy;
  final MedicationType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isLoading;
  final String? errorMessage;

  bool get isEditing => medication != null;

  MedicationFormState copyWith({
    Medication? medication,
    String? animalId,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? notes,
    String? prescribedBy,
    MedicationType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MedicationFormState(
      medication: medication ?? this.medication,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
